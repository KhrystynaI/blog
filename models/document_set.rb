# == Schema Information
#
# Table name: document_sets
#
#  id              :integer          not null, primary key
#  doc_id          :string
#  order_id        :string
#  title           :string
#  version         :string
#  state           :string           default("new")
#  created_by      :string
#  updated_by      :string
#  assigned_to     :integer
#  customer_id     :integer
#  vendor_id       :integer
#  product_id      :integer
#  contract_id     :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  subscription_id :integer
#  expiry_date     :datetime
#  published_at    :datetime
#

class DocumentSet < ActiveRecord::Base

  STATES = [:new, :in_progress, :complete, :published, :archived]

  include Questionable
  include Versions
  include DocumentSetStatus
  include DocumentSetSearch
  include DocumentSetFooter
  include DocumentSetPdf
  include PgSearch
  include ActiveAction

  include PublicActivity::Model
  tracked owner: ->(controller, model) { controller&.current_user },
          parameters: ->(controller, model) do
            Hash(changes: model.changes, doc_id: model.doc_id)
          end,
          doc_id: ->(controller, model) { model.doc_id },
          document_set_id: ->(controller, model) { model.id }

  delegate :start_date, :end_date, :phone, :duration, :price,
           to: :contract, allow_nil: true

  belongs_to :assignee, foreign_key: 'assigned_to', class_name: User
  belongs_to :customer # should we delegate these three methods to a contract?
  belongs_to :vendor # optionally
  belongs_to :product # optionally
  belongs_to :contract

  has_many :document_links, dependent: :destroy
  has_many :documents, through: :document_links

  has_many :ds_questions, dependent: :destroy

  has_many :order_items, dependent: :destroy
  has_many :subscribers, through: :order_items

  pg_search_scope :pg_search,
                  :against => [:title, :doc_id],
                  :using => {
                    :tsearch => {:prefix => true}
                  }

  def self.policy_class
    ActiveAdmin::DocumentSetPolicy
  end

  def order_item_ids
    order_items.pluck(:id)
  end

  def subscriber_ids
    order_items.pluck(:subscriber_id)
  end

  acts_as_taggable

  validates :doc_id, presence: true
  validates :title, presence: true

  def name
    "#{doc_id} #{title} V.#{version}"
  end

  def display_name
    "#{doc_id} #{title}"
  end
  alias_method :display_title, :display_name

  def full_title
    "#{doc_id} #{title} V.#{version}"
  end

  def filename
    name.parameterize
  end

  before_save :update_expiry_date
  before_save :update_state
  after_touch :update_state!

  scope :customer, ->(customer_id) do
    where(customer_id: customer_id)
  end

  scope :latest, -> do
    document_sets = []
    order(version: 'desc').each do |ds|
      document_sets << ds if !document_sets.include?(ds) && !document_sets.map(&:doc_id).include?(ds.doc_id)
    end
    DocumentSet.where(id: document_sets.map(&:id))
  end

  scope :expired, -> do
    active.where('expiry_date < ?', Time.now.beginning_of_day)
  end

  scope :expire_soon, -> do
    active.where('expiry_date >= ? and expiry_date < ?',
          Time.now.beginning_of_day,
          Time.now.beginning_of_month + 4.months)
  end

  def self.doc_ids
    self.pluck('doc_id').uniq.sort
  end

  def self.text_search(query)
    if query.present?
      search(query)
    else
      all
    end
  end

  def fill_new_document_set
    self.version = '1'
    self.create_unique_doc_id
  end

  # return questions of documents or contracts
  def ds_questions_by_object(questions_object)
    ql_ids = self.ds_questions.pluck(:question_link_id)
    ids = QuestionLink.where(id: ql_ids, subject: questions_object).pluck(:question_id)
    Question.where(id: ids)
  end

  def all_questions
    questions_id_array = []
    if self.documents.count > 0
      self.documents.each do |document|
        questions_id_array << self.ds_questions_by_object(document).pluck(:id)
      end
    end
    if self.contract
      questions_id_array << self.ds_questions_by_object(contract).pluck(:id)
    end
    questions_id_array << self.questions.pluck(:id)
    Question.where(id: questions_id_array.uniq)
  end

  # return array consist of hashes with such attributes: category, question, answer
  # example: [{category: "Cat1", question: "Q1", answer: "Ans1", original_text: "OT1"},
  # {category: "Cat1", question: "Q2", answer: "Ans2", original_text: "OT2"}]
  def all_questions_answers
    questions_answers_array = []
    ds_questions.each do |ds_question|
      question = ds_question.question_link.question.text
      category = ds_question.question_link.question.category.try(:name)
      answer = ds_question.actual_answer
      original_text = ds_question.question_link.original_text
      questions_answers_array << {
        category: category,
        question: question,
        answer: answer,
        original_text: original_text,
        question_link_id: ds_question.question_link_id,
        position: -1
      }
    end

    self.question_links.joins(:question).each do |question_link|
      question = question_link.question.text
      category = question_link.question.category&.name
      category_position = question_link.question.category&.position
      position = question_link.question.category&.position.to_i * 1000 + question_link.question.position.to_i
      answer = question_link.answer
      original_text = question_link.original_text
      questions_answers_array << {
        position: position,
        category_position: category_position,
        category: category,
        question: question,
        answer: answer,
        original_text: original_text,
        question_link_id: question_link.id
      }
    end
    questions_answers_array.sort_by do |question|
      question[:category_position].to_i * 1000 + question[:position].to_i
    end
  end

  def ds_link_questions(array)
    array.each do |question_attributes|
      # TODO unsafe
      question = Question.find(question_attributes[:question_id])
      if question.present? && question_attributes[:question_object_class_name].blank?
        QuestionLink.create!(subject: self, question: question)
      else
        subject = question_attributes[:question_object_class_name].
            classify.constantize.find(question_attributes[:question_object_id])
        question_link = QuestionLink.find_by(subject: subject, :question => question)
        ds_question = self.ds_questions.new
        ds_question.question_link_id = question_link.id
        ds_question.save!
      end
    end
  end

  def document_files
    documents.map(&:file_links).flatten
  end

  def contract_files
    contract&.file_links || []
  end

  def files
    document_files + contract_files
  end

  def one_page
    documents.detect(&:one_page?)
  end

  def one_page?
    one_page.present?
  end

  def expiry_date_for(user_id)
    order_items.active.where(subscriber_id: user_id).first.try(:expiry_date) 
  end

  def audit_trail
    Activity.where(document_set_id: id).order(created_at: 'desc')
  end

  def full_audit_trail
    audit_trails = []
    audit_trails += audit_trail
    documents.each {|doc| audit_trails += doc.audit_trail}
    questions.each {|question| audit_trails += question.audit_trail}
    audit_trails.sort_by! &:created_at
  end

  def order_items_expiry_date
    order_items.active.maximum('expiry_date')
  end

  def order_items_expire_in?(days)
    return false if order_items_expiry_date.nil?

    order_items_expiry_date - Time.now.beginning_of_day <= days
  end

  def order_items_expired?
    return false if order_items_expiry_date.nil?

    order_items_expiry_date < Time.now.beginning_of_day
  end

  def update_expiry_date
    PublicActivity.without_tracking do
      new_date = order_items_expiry_date
      update_columns(expiry_date: new_date) if expiry_date != new_date
    end
  end

  def update_state
    unless new_record? || active_action == :import
      self.state = 'in_progress' if self.new?
    end
  end

  def update_state!
    update_state
    save!
  end

  def touch
    super
    update_expiry_date
  end
end

# == Schema Information
#
# Table name: documents
#
#  id                 :integer          not null, primary key
#  doc_id             :string
#  document_type_name :string
#  title              :string
#  version            :string
#  expiry_date        :datetime
#  vendor_id          :integer
#  product_id         :integer
#  state              :string           default("new")
#  created_by         :string
#  updated_by         :string
#  assigned_to        :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  customer_id        :integer
#

class Document < ActiveRecord::Base

  STATES = [:new, :in_progress, :archived]

  include Questionable
  include Versions
  include Fileable
  include DocumentStatus
  include PgSearch

  include PublicActivity::Model
  tracked owner: ->(controller, model) { controller&.current_user },
          parameters: ->(controller, model) do
            Hash(changes: model.changes, doc_id: model.doc_id)
          end,
          doc_id: ->(controller, model) { model.doc_id }

  def self.policy_class
    ActiveAdmin::DocumentPolicy
  end

  def display_title
    "#{doc_id} #{title} (V.#{version})"
  end

  belongs_to :assignee, foreign_key: 'assigned_to', class_name: User
  belongs_to :document_type, foreign_key: 'document_type_name'
  belongs_to :customer
  belongs_to :vendor # optionally
  belongs_to :product # optionally

  validates :doc_id, presence: true
  validates :title, presence: true

  has_many :document_links, dependent: :destroy

  pg_search_scope :search,
                  :against => [:title, :doc_id],
                  :using => {
                    :tsearch => {:prefix => true}
                  }

  def self.text_search(query)
    if query.present?
      search(query)
    else
      all
    end
  end

  scope :untyped, -> do
    where(document_type_name: ['', nil])
  end

  scope :footers, -> do
    where(document_type_name: 'footer')
  end

  def display_name
    "#{doc_id} #{title}"
  end

  def fill_new_document
    self.version = '1'
    self.create_unique_doc_id
  end

  # TODO: move out of the Document class.
  # this is not a property of the Document.
  # So why do you ask the Document about?
  def can_add_document?
    !one_page? ||
      (one_page? && file_links.count == 0)
  end

  # TODO: move out of the Document class.
  # So why do you ask the Document about?
  def multiple_choose?
    !one_page?
  end

  def footer?
    document_type_name == DocumentType::FOOTER
  end

  def one_page?
    document_type_name == DocumentType::ONE_PAGE
  end

  acts_as_taggable

  def self.import_file(file:, type:, doc_id: nil)
    title = File.basename(file, '.pdf').encode('UTF-8')
    document = ::Document.where(title: title).first

    ActiveRecord::Base.transaction do
      document ||= ::Document.new(
        doc_id: doc_id,
        title: title,
        document_type_name: type,
        version: '0.0.1',
        state: :new)

      document.file_links.each(&:destroy)
      document.file_links.clear

      file_link = document.file_links.build
      File.open(file, 'rb') do |f|
        file_link.file = f
      end
      file_link.save

      document.save!
    end

    document
  end

  def audit_trail
    Activity.where(trackable_type: self.class.name, trackable_id: id).order(created_at: 'desc')
  end

end

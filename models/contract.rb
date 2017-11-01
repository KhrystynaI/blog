# == Schema Information
#
# Table name: contracts
#
#  id                :integer          not null, primary key
#  title             :string
#  doc_id            :string
#  version           :string
#  vendor_id         :integer
#  product_id        :integer
#  customer_id       :integer
#  start_date        :datetime
#  end_date          :datetime
#  phone             :string
#  duration          :float
#  price             :float
#  expiry_date       :datetime
#  state             :string           default("new")
#  assigned_to       :integer
#  created_by        :integer
#  updated_by        :integer
#  contract_owner_id :integer
#

class Contract < ActiveRecord::Base
  STATES = [:in_progress, :published]

  include Questionable
  include Versions
  include Fileable
  include DocumentStatus
  include PgSearch

  include PublicActivity::Model

  tracked owner: ->(controller, model) { controller&.current_user },
          parameters: ->(controller, model) do
            Hash(changes: model.changes)
          end

  belongs_to :vendor
  belongs_to :customer
  belongs_to :product
  belongs_to :assignee, foreign_key: 'assigned_to', class_name: User
  belongs_to :contract_owner

  has_many :fields, as: 'subject', dependent: :delete_all
  accepts_nested_attributes_for :fields, :reject_if => :all_blank, :allow_destroy => true

  def self.policy_class
    ActiveAdmin::ContractPolicy
  end

  acts_as_taggable

  pg_search_scope :search,
                  :against => [:title],
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

  def display_title
    title
  end

  def fill_new_document
    self.version = '1'
    self.create_unique_doc_id
  end
end

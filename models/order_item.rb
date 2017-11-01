# == Schema Information
#
# Table name: order_items
#
#  id              :integer          not null, primary key
#  order_id        :string
#  expiry_date     :datetime
#  subscriber_id   :integer
#  archived        :boolean          default(FALSE)
#  state           :string           default("new")
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  document_set_id :integer
#

class OrderItem < ActiveRecord::Base
  belongs_to :document_set, touch: true
  belongs_to :subscriber, class_name: 'User'

  include PublicActivity::Model
  tracked owner: ->(controller, model) { controller&.current_user },
          parameters: ->(controller, model) do
            Hash(changes: model.changes, attributes: model.attributes )
          end,
          doc_id: ->(controller, model) { model.document_set.doc_id },
          document_set_id: ->(controller, model) { model.document_set.id }


  def display_title
    "Order: #{order_id} Exp: #{expiry_date}"
  end

  accepts_nested_attributes_for :subscriber

  validates :document_set_id, presence: true

  after_commit :reindex_document_set

  scope :archived, -> do
    where(archived: true)
  end

  scope :active, -> { where(archived: false) }

  def active?
    !archived
  end

  private

  def reindex_document_set
    document_set.reindex
  end
end

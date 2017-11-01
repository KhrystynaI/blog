# == Schema Information
#
# Table name: customers
#
#  id         :integer          not null, primary key
#  name       :string
#  path       :string
#  access_key :string
#

class Customer < ActiveRecord::Base
  has_many :users

  include PublicActivity::Model

  tracked owner: ->(controller, model) { controller&.current_user },
          parameters: ->(controller, model) do
            Hash(changes: model.changes)
          end

  def display_title
    name
  end

  include Questionable

  has_many :document_sets, dependent: :destroy
  has_many :contracts, dependent: :destroy

  validates :path, presence: true

  def to_param
    path
  end

  def self.collection
    all.each_with_object({}) do |record, col|
      col[record.id] = record.name
    end
  end
end

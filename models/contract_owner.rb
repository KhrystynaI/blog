# == Schema Information
#
# Table name: contract_owners
#
#  id      :integer          not null, primary key
#  name    :string
#  address :string
#

class ContractOwner < ActiveRecord::Base
  has_many :contracts
  include PublicActivity::Model
  tracked owner: ->(controller, model) { controller&.current_user },
          parameters: ->(controller, model) do
            Hash(changes: model.changes)
          end

  def display_title
    name
  end

  def self.collection
    all.each_with_object({}) do |record, col|
      col[record.id] = record.name
    end
  end
end

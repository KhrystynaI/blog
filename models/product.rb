# == Schema Information
#
# Table name: products
#
#  id        :integer          not null, primary key
#  name      :string
#  note      :string
#  vendor_id :integer
#

class Product < ActiveRecord::Base
  include PublicActivity::Model

  tracked owner: ->(controller, model) { controller&.current_user },
          parameters: ->(controller, model) do
            Hash(changes: model.changes)
          end

  default_scope { order(name: :asc) }

  def display_title
    name
  end

  belongs_to :vendor
end

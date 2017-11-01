# == Schema Information
#
# Table name: vendors
#
#  id             :integer          not null, primary key
#  name           :string
#  parent_company :string
#  location       :string
#  terms_source   :string
#  terms_link     :string
#  notes          :string
#

class Vendor < ActiveRecord::Base
  include PublicActivity::Model
  tracked owner: ->(controller, model) { controller&.current_user },
          parameters: ->(controller, model) do
            Hash(changes: model.changes)
          end

  default_scope { order(name: :asc) }

  def display_title
    "#{name} #{location}"
  end

  has_many :products
end

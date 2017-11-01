# == Schema Information
#
# Table name: question_categories
#
#  id       :integer          not null, primary key
#  name     :string
#  note     :string
#  position :integer
#

class QuestionCategory < ActiveRecord::Base
  has_many :questions
  include PublicActivity::Model
  tracked owner: ->(controller, model) { controller&.current_user },
          parameters: ->(controller, model) do
            Hash(changes: model.changes)
          end

  def self.default_scope
    order(position: 'ASC')
  end

  def display_title
    name
  end

  def self.collection(with_blank: false)
    result = all.each_with_object({}) do |record, col|
      col[record.id] = record.name
    end
    result[nil] = '' if with_blank
    result
  end
end

# == Schema Information
#
# Table name: question_sets
#
#  id       :integer          not null, primary key
#  title    :string
#  position :integer
#

class QuestionSet < ActiveRecord::Base
  validates :title, presence: true
  validates :title, uniqueness: true

  include Questionable
  include PublicActivity::Model
  tracked owner: ->(controller, model) { controller&.current_user },
          parameters: ->(controller, model) do
            Hash(changes: model.changes)
          end

  def display_title
    title
  end
end

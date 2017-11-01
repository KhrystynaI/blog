# == Schema Information
#
# Table name: questions
#
#  id          :integer          not null, primary key
#  category_id :integer
#  text        :string
#  note        :string
#  custom      :boolean          default(TRUE)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  position    :integer
#  deleted_at  :datetime
#

class Question < ActiveRecord::Base
  include PublicActivity::Model

  acts_as_paranoid without_default_scope: true

  tracked owner: ->(controller, model) { controller&.current_user },
          parameters: ->(controller, model) do
            Hash(changes: model.changes)
          end

  def display_title
    text
  end

  belongs_to :category, class_name: 'QuestionCategory', foreign_key: 'category_id'

  scope :standard, -> do
    where(custom: false).without_deleted
  end

  scope :custom, -> do
    where(custom: true).without_deleted
  end

  default_scope :ordered do
    order(position: 'ASC')
  end

  def self.collection
    standard.each_with_object({}) do |record, col|
      col[record[:name]] = record[:text]
    end
  end

  # for ActiveAdmin
  def display_name
    "#{category.try(:name)}: #{text}"
  end

  def standard?
    !custom
  end

  def custom?
    custom == true
  end

  def audit_trail
    Activity.where(trackable_type: self.class.name, trackable_id: id).order(created_at: 'desc')
  end

end

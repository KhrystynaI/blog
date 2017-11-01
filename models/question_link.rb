# == Schema Information
#
# Table name: question_links
#
#  id            :integer          not null, primary key
#  question_id   :integer
#  subject_id    :integer
#  subject_type  :string
#  position      :integer
#  answer        :string
#  original_text :string
#

class QuestionLink < ActiveRecord::Base
  belongs_to :question
  belongs_to :subject, polymorphic: true, touch: true
  has_many :ds_questions, dependent: :destroy
  delegate :category, to: :question

  def self.with_subject(subject)
    if subject.is_a?(Symbol) || subject.is_a?(String)
      assignments = QuestionLink.where(subject_type: subject)
    else
      assignments = QuestionLink.where(
        subject_type: subject.class.to_s,
        subject_id: subject.id)
    end

    assignments.order(:position)
  end

  def self.bulk_update(updates)
    return unless updates
    transaction do
      updates.each do |link_id, changes|
        link = QuestionLink.find_by!(id: link_id)
        link.update!(changes.permit(:answer, :original_text))
      end
    end
  end

  # for ActiveAdmin
  def display_name
    "#{subject_type}#{subject_id}: #{question.text}"
  end
end

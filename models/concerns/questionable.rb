require 'active_support/concern'

module Questionable
  extend ActiveSupport::Concern

  included do
    has_many :question_links, as: :subject, dependent: :delete_all
    has_many :questions, through: :question_links
  end

  def has_question_text?(text)
    questions.any?{ |question| question.text.downcase == text.downcase }
  end

  def add_custom_question(text:, category_id: nil)
    raise 'Question allready added.' if has_question_text?(text)

    transaction do
      question = Question.custom.create!(text: text, category_id: category_id)
      questions << question
    end
  end

  def link_questions(question_ids)
    question_ids.each do |question_id|
      link_question(question_id)
    end
  end

  private

  # This method is rather technical, thus it is private.
  # It does not update `object.questions` collection.
  # Use `object.questions << question` where possible instead.
  def link_question(question_id)
    link = QuestionLink.new
    link.subject = self
    link.question_id = question_id
    link.save!
  end
end

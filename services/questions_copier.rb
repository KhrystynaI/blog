class QuestionsCopier

  def self.copy_questions_and_answers(source: , target: , with_answers:)
    ActiveRecord::Base.transaction do
      source.question_links.each do |question_link|
        new_question_link = question_link.dup
        new_question_link.subject = target
        unless with_answers
          new_question_link.answer = nil
          new_question_link.original_text = nil
        end
        new_question_link.save!
      end
      if target.class.name == "DocumentSet"
        # doc&contract questions
        source.ds_questions.each do |ds_question|
          new_ds_question = ds_question.dup
          new_ds_question.document_set = target
          new_ds_question.answer = '' unless with_answers
          new_ds_question.save!
        end
      end
    end
  end
end

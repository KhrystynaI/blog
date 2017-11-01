# == Schema Information
#
# Table name: ds_questions
#
#  id               :integer          not null, primary key
#  question_link_id :integer
#  document_set_id  :integer
#  answer           :string
#

class DsQuestion < ActiveRecord::Base
  belongs_to :question_link, touch: true
  belongs_to :document_set, touch: true

  def actual_answer
    if self.answer
      answer = self.answer
    else
      answer = self.question_link.answer
    end
  end

end

# == Schema Information
#
# Table name: document_links
#
#  id              :integer          not null, primary key
#  document_id     :integer
#  document_set_id :integer
#

class DocumentLink < ActiveRecord::Base
  belongs_to :document
  belongs_to :document_set, touch: true
end

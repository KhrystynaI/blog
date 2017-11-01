# == Schema Information
#
# Table name: document_types
#
#  name        :string           primary key
#  title       :string
#  description :string
#  metadata    :string
#

class DocumentType < ActiveRecord::Base
  ONE_PAGE = 'one_page_document'
  FOOTER = 'footer'

  self.primary_key = :name
  validates :name, presence: true

  def to_param
    name
  end

  def self.collection
    all.each_with_object({}) do |record, col|
      col[record[:name]] = record[:title]
    end
  end
end

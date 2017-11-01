# == Schema Information
#
# Table name: file_links
#
#  id                :integer          not null, primary key
#  subject_id        :integer
#  subject_type      :string
#  file_text         :string
#  file_id           :string           not null
#  file_filename     :string           not null
#  file_size         :string           not null
#  file_content_type :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class FileLink < ActiveRecord::Base
  PAGE_SEPARATOR = "\n\n\t\n\n"

  belongs_to :subject, polymorphic: true
  attachment :file, extension: "pdf"
  acts_as_taggable
  before_save :extract_text

  def extract_text
    return unless self.file

    self.file_text = parse_pdf
  rescue => error
    warn " - Error reading #{self.file_filename}"
    warn " -  #{error.message}"
  end

  private

  def parse_pdf
    reader = PDF::Reader.new(self.file.download)
    result = reader.pages.map(&:text).join(PAGE_SEPARATOR)
    ::Tools::String::Encoding.strip_invalid_chars(result)
  end
end

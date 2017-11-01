require 'active_support/concern'
module DocumentSetPdf
  extend ActiveSupport::Concern

  included do
    has_one :pdf, as: :subject, dependent: :destroy, class_name: 'FileLink'

    accepts_attachments_for :pdf, append: true

    before_save :remove_pdf, if: ->(ds) { ds.one_page }
  end

  def remove_pdf
    pdf.destroy! if pdf
  end

  def generate_pdf(footer_page_num: 1)
    if one_page&.files.blank?
      raise "Cannot generate final pdf: DocumentSet '#{title}' does not contain a one page file."
    end

    temp_file_path = combine_one_page_and_footer(footer_page_num: footer_page_num)

    set_pdf_file(temp_file_path)
  end

  private

  def set_pdf_file(file_path)
    pdf.destroy! if pdf

    file_link = FileLink.new(subject: self)
    File.open(file_path, "rb") do |file|
      file_link.file = file
    end

    self.pdf = file_link
  end

  def combine_one_page_and_footer(footer_page_num:)
    pdf_file = Tempfile.new(["final-#{filename}", ".pdf"], File.join(Rails.root, "tmp"))

    one_page_file_path = one_page.file.download.path

    if footer.present? && footer.file_link.present?
      footer_file_path = footer.file_link.file.download.path

      if footer_page_num.blank?
        (CombinePDF.load(one_page_file_path) << CombinePDF.load(footer_file_path)).save pdf_file.path
      else
        tmp_pdf = CombinePDF.load(one_page_file_path)
        tmp_pdf.pages[footer_page_num.to_i-1] << CombinePDF.load(footer_file_path).pages[0]
        tmp_pdf.save pdf_file.path
      end
    else
      FileUtils.cp(one_page_file_path, pdf_file.path)
    end

    pdf_file.path
  end
end

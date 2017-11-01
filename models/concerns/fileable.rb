require 'active_support/concern'

module Fileable
  extend ActiveSupport::Concern

  included do
    has_many :file_links, as: :subject, dependent: :delete_all
    accepts_attachments_for :file_links, append: true
  end

  def file_link
    file_links.first
  end

  def file
    file_links.first.try(:file)
  end

  def files
    file_links.map(&:file)
  end

  def add_file(f)
    file_links.build(file: f)
  end
end

require 'active_support/concern'
module DocumentSetFooter
  extend ActiveSupport::Concern

  def footer
    documents.detect(&:footer?)
  end

  def remove_footer
    documents.delete(footer) if footer
  end

  def set_footer(new_footer)
    remove_footer if footer != new_footer
    documents << new_footer
    save
  end
end

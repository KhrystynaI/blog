require 'active_support/concern'

module Versions
  extend ActiveSupport::Concern
  extend self

  def versions
    # TODO add customer criteria
    self.class.where(doc_id: doc_id).order(version: 'asc')
  end

  def version_list
    self.class.where(doc_id: doc_id).pluck(:version)
  end

  def generate_new_version
    self.class.where(doc_id: doc_id).pluck(:version).
        map{ |ver| ver.to_s.split('.').last.to_i }.max.to_i + 1
  end

  def copy_version_attributes(source)
    self.doc_id = source.doc_id
    self.title = source.title if self.has_attribute?(:title)
    self.assigned_to = source.assigned_to if self.has_attribute?(:assigned_to)
    self.document_type = source.document_type if self.has_attribute?(:document_type_name)
    self.customer = source.customer if self.has_attribute?(:customer_id)
    self.vendor = source.vendor if self.has_attribute?(:vendor_id)
    self.product = source.product if self.has_attribute?(:product_id)
    self.try(:tag_list) << source.try(:tag_list)
  end

  def create_unique_doc_id(attempt: 0)
    return 'Cannot generate Doc ID' if attempt > 3

    new_id = self.class.order(id: 'DESC').limit(1000).pluck(:doc_id).map(&:to_i).max.to_i + 1
    if self.class.find_by(doc_id: new_id)
      create_unique_doc_id(attempt: attempt + 1)
    end
    self.doc_id = new_id
  end
end

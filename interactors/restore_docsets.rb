class RestoreDocsets
  include Interactor

  def call
    docsets = select_active(DocumentSet.archived)
    docsets.each(&:restore)
    context.result = docsets.map &:full_title
  end

  def restore_docsets(docsets)
    docsets.each do |docset|
      docset.restore
    end
  end

  def select_active(docsets)
    docsets.select do |docset|
      docset.order_items.active.exists? && !docset.order_items_expired?
    end
  end
end

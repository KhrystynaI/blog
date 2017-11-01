class MergeVendors
  include Interactor

  def call
    vendors = Vendor.all

    duplicates = group_duplicates(vendors)

    #result = merge_duplicates(duplicates).select { |_, duplicates| duplicates.any? }
    context.result = duplicates
  end

  def group_duplicates(items)
    head = items.first
    tail = items[1..-1]

    similars = find_similars(like: head, list: tail)

    group = {head => similars}

    remaining = tail - similars

    if remaining.any?
      group.merge group_duplicates(remaining)
    else
      group
    end
  end

  def find_similars(like:, list:)
    list.select do |item|
      similar?(item.name.to_s.strip, like.name.to_s.strip)
    end
  end

  def merge_items(items:, to:)
    (Contract DocumentQuestion DocumentSets Document Product).each do |relation|
      relation.where(vendor_id: items.map(&:id)).update_all(vendor_id: to.id)
    end
  end

  def similar?(name1, name2)
    norm_name1, norm_name2 = norm(name1), norm(name2)
    norm_name1 == norm_name2 ||
      (norm_name1.length > 2 && norm_name2.length > 2 &&
        Similarity::Levenshtein.distance(norm_name1, norm_name2) < 2)
  end

  def norm(name)
    name.to_s.gsub(' ', '')
  end
end

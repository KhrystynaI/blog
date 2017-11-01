json.itemsCount @total
json.data @document_sets do |docset|
  json.id docset.id
  json.state docset.state
  json.title docset.title
  json.version docset.version
  json.doc_id docset.doc_id
  json.question_count docset.question_links.count
end

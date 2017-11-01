json.itemsCount @total
json.data @documents.as_json(only: [:id, :state, :document_type_name, :title, :version, :doc_id])


json.itemsCount @total
json.data @documents do |doc|
  json.id doc.id
  json.state doc.state
  json.title doc.title
  json.version doc.version
  json.doc_id doc.doc_id
  json.document_type_name doc.document_type_name
  json.doc_type doc.document_type&.title
end

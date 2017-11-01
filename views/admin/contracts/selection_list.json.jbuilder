json.total_count @contracts.count
json.incomplete_results false
json.items []
json.items @contracts.each do |contract|
  json.id contract.id
  json.title contract.title
  json.state contract.state
  json.version contract.version
end

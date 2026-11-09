namespace '/api/v1' do
  get('/geeks') { collection_to_api(Geek.order(:id)) }
  get('/geek/:id') { find_record(Geek).values.to_json }
end

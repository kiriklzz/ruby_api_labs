namespace '/api/v1' do
  get('/applies') { collection_to_api(Apply.order(:id)) }
  get('/applies_read') { collection_to_api(Apply.read.order(:id)) }
  get('/applies_unread') { collection_to_api(Apply.unread.order(:id)) }
  get('/apply/:id') { find_record(Apply).values.to_json }
end

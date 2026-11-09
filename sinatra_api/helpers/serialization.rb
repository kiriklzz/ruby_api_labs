helpers do
  def collection_to_api(collection)
    JSON.generate(collection.map(&:to_api))
  end
end

before '/api/*' do
  content_type :json
end

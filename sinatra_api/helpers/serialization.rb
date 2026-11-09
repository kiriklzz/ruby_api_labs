helpers do
  def collection_to_api(collection)
    JSON.generate(collection.map(&:to_api))
  end

  def find_record(model)
    id = params[:id]
    record = model[id.to_i] if id.match?(/\A[1-9]\d{0,9}\z/)
    halt 404, { message: 'Document Not Found', status: 404, params_id: id }.to_json unless record
    record
  end

  def filter_text(key)
    value = params[key]
    halt 400, { message: "#{key} must be a string" }.to_json unless value.is_a?(String)
    value
  end
end

before '/api/*' do
  content_type :json
  # The handout also uses semicolons between query parameters.
  params.merge!(Rack::Utils.parse_nested_query(request.query_string, '&;')) if request.query_string.include?(';')
end

error Sequel::ValidationFailed do
  status 422
  { errors: env['sinatra.error'].errors }.to_json
end

not_found do
  content_type :json
  { message: 'Document Not Found', status: 404 }.to_json
end

namespace '/api/v1' do
  get '/companies' do
    companies = Company.dataset
    companies = companies.by_name(filter_text('name')) if params.key?('name')
    companies = companies.by_location(filter_text('location')) if params.key?('location')
    collection_to_api(companies.order(:id))
  end

  get '/company/:id' do
    find_record(Company).values.to_json
  end

  get '/company_jobs' do
    name = params.key?('name') ? filter_text('name') : nil
    collection_to_api(name ? Company.company_jobs(name).order(:id) : [])
  end

  post '/companies' do
    input = params
    if request.media_type == 'application/json'
      begin
        input = JSON.parse(request.body.read)
      rescue JSON::ParserError
        halt 400, { message: 'Invalid JSON' }.to_json
      end
    end
    halt 400, { message: 'Expected an object' }.to_json unless input.is_a?(Hash)
    attributes = input.slice('name', 'location')
    unless attributes.values.all? { |value| value.is_a?(String) }
      halt 422, { message: 'name and location must be strings' }.to_json
    end
    company = Company.create(attributes)
    status 201
    headers 'Location' => "/api/v1/company/#{company.id}"
    company.values.to_json
  end
end

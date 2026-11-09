namespace '/api/v1' do
  get '/jobs' do
    jobs = Job.dataset
    jobs = jobs.by_name(filter_text('name')) if params.key?('name')
    jobs = jobs.by_place(filter_text('place')) if params.key?('place')
    if params.key?('company')
      jobs = jobs.where(company_id: Company.by_name(filter_text('company')).select(:id))
    end
    collection_to_api(jobs.order(:id))
  end

  get '/jobs_company/:name' do
    company = Company.first(name: params[:name])
    halt 404, { message: 'Company Document Not Found', status: 404 }.to_json unless company
    collection_to_api(company.jobs_dataset.order(:id))
  end

  get '/job/:id' do
    find_record(Job).values.to_json
  end
end

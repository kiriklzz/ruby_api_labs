ENV['RACK_ENV'] = 'test'
require 'minitest/autorun'
require 'rack/test'
require_relative '../api_sinatra_postgres'

class ApiTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def run
    DB.transaction(rollback: :always) { super }
  end

  def setup
    [:applies, :jobs, :geeks, :companies].each { |table| DB[table].delete }
    @company = Company.create(name: 'MoGo', location: 'New York')
    @other = Company.create(name: 'Wirkkle', location: 'London')
    @job = Job.create(name: 'Sinatra React', place: 'Remote', company: @company)
    @geek = Geek.create(name: 'Mike', stack: 'Ruby')
    Apply.create(job: @job, geek: @geek, read: true)
    Apply.create(job: @job, geek: @geek, read: false)
  end

  def json
    assert_equal 'application/json', last_response.media_type
    JSON.parse(last_response.body)
  end

  def test_company_filters
    get '/api/v1/companies', name: 'mo', location: 'ne'
    assert_equal [@company.id], json.map { |row| row['id'] }
    get '/api/v1/companies', name: 'Mo', location: 'Si'
    assert_equal [], json
    get '/api/v1/companies', location: 'london'
    assert_equal [@other.id], json.map { |row| row['id'] }
    ['%', "' OR 1=1 --"].each do |name|
      get '/api/v1/companies', name: name
      assert_equal [], json
    end
    get '/api/v1/companies?name[]=Mo'
    assert_equal 400, last_response.status
  end

  def test_jobs_and_associations
    get '/api/v1/jobs', name: 'react', place: 'rem', company: 'mo'
    assert_equal [@job.id], json.map { |row| row['id'] }
    get '/api/v1/company_jobs', name: 'mo'
    assert_equal [@job.id], json.map { |row| row['id'] }
    get '/api/v1/company_jobs', name: 'missing'
    assert_equal [], json
    get '/api/v1/jobs_company/MoGo'
    assert_equal [@job.id], json.map { |row| row['id'] }
    get '/api/v1/jobs_company/missing'
    assert_equal 404, last_response.status
    get '/api/v1/jobs_company/Wirkkle'
    assert_equal [], json
  end

  def test_applies_and_geeks
    get '/api/v1/applies_read'
    assert_equal [true], json.map { |row| row['read'] }.uniq
    get '/api/v1/applies_unread'
    assert_equal [false], json.map { |row| row['read'] }.uniq
    get '/api/v1/geeks'
    assert_includes json.map { |row| row['id'] }, @geek.id
  end

  def test_single_record_and_missing_ids
    get "/api/v1/job/#{@job.id}"
    assert_equal @job.name, json['name']
    get "/api/v1/company/#{@company.id}"
    assert_equal @company.name, json['name']
    ['0', 'abc', '1oops', '9999999999'].each do |id|
      get "/api/v1/job/#{id}"
      assert_equal 404, last_response.status
    end
  end

  def test_create_company_with_json_and_form
    post '/api/v1/companies', { name: 'Dieter', location: 'Ubud', id: 999 }.to_json,
         'CONTENT_TYPE' => 'application/json'
    assert_equal 201, last_response.status
    assert_equal 'Dieter', json['name']
    refute_equal 999, json['id']
    post '/api/v1/companies', name: 'Form', location: 'London'
    assert_equal 201, last_response.status
  end

  def test_invalid_create_does_not_write
    count = Company.count
    ['{', '[]', '{"name":3,"location":"Ubud"}', '{"name":""}'].each do |body|
      post '/api/v1/companies', body, 'CONTENT_TYPE' => 'application/json'
      assert_includes [400, 422], last_response.status
    end
    assert_equal count, Company.count
  end
end

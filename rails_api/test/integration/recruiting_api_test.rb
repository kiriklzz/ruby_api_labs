require "test_helper"

class RecruitingApiTest < ActionDispatch::IntegrationTest
  setup do
    @company = Company.create!(name: "MoGo", location: "New York")
    @other_company = Company.create!(name: "Wirkkle", location: "London")
    @job = @company.jobs.create!(name: "Ruby React", place: "Remote")
    @other_job = @other_company.jobs.create!(name: "Java", place: "Contract")
    @geek = Geek.create!(name: "Mike", stack: "Ruby React")
    @other_geek = Geek.create!(name: "Alex", stack: "Java")
    @apply = Apply.create!(job: @job, geek: @geek, read: true, invited: true)
    @other_apply = Apply.create!(job: @other_job, geek: @other_geek)
  end

  test "all resources have list and detail routes with JSON responses" do
    { companies: @company, jobs: @job, geeks: @geek, applies: @apply }.each do |resource, record|
      get "/v1/#{resource}"
      assert_response :success
      assert_equal "application/json", response.media_type
      assert_includes response.parsed_body.map { |item| item["id"] }, record.id

      get "/v1/#{resource}/#{record.id}"
      assert_response :success
      assert_equal record.id, response.parsed_body["id"]
      assert_not response.parsed_body.key?("created_at")
    end
  end

  test "text filters are case insensitive and can be combined" do
    get "/v1/companies", params: { name: "mo", location: "new" }
    assert_equal [@company.id], response.parsed_body.map { |item| item["id"] }

    get "/v1/jobs", params: { name: "ruby", place: "remote" }
    assert_equal [@job.id], response.parsed_body.map { |item| item["id"] }

    get "/v1/geeks", params: { name: "mi", stack: "react" }
    assert_equal [@geek.id], response.parsed_body.map { |item| item["id"] }

    get "/v1/companies", params: { name: "mo", location: "London" }
    assert_equal [], response.parsed_body
  end

  test "percent in a text filter is treated as a literal character" do
    get "/v1/jobs", params: { name: "%" }

    assert_response :success
    assert_equal [], response.parsed_body
  end

  test "company jobs are scoped to that company" do
    get "/v1/companies/#{@company.id}/jobs"
    assert_equal [@job.id], response.parsed_body.map { |item| item["id"] }

    get "/v1/companies/#{@company.id}/jobs/#{@other_job.id}"
    assert_response :not_found

    patch "/v1/companies/#{@company.id}/jobs/#{@other_job.id}", params: { name: "changed" }, as: :json
    assert_response :not_found
    assert_equal "Java", @other_job.reload.name
  end

  test "nested job creation uses the company from the route" do
    post "/v1/companies/#{@company.id}/jobs",
      params: { name: "Node", place: "Remote", company_id: @other_company.id }, as: :json

    assert_response :created
    assert_equal @company.id, response.parsed_body["company_id"]
  end

  test "standalone job can be transferred to another company" do
    patch "/v1/jobs/#{@job.id}", params: { company_id: @other_company.id }, as: :json

    assert_response :success
    assert_equal @other_company.id, @job.reload.company_id
  end

  test "companies can be created and edited" do
    assert_difference "Company.count", 1 do
      post "/v1/companies", params: { name: "Artesis", location: "Saint-Petersburg" }, as: :json
    end
    assert_response :created
    id = response.parsed_body["id"]

    put "/v1/companies/#{id}", params: { location: "London" }, as: :json
    assert_response :success
    assert_equal "London", Company.find(id).location
  end

  test "geeks can be created edited and deleted with their applies" do
    post "/v1/geeks", params: { name: "Kate", stack: "PHP" }, as: :json
    assert_response :created
    id = response.parsed_body["id"]

    patch "/v1/geeks/#{id}", params: { stack: "Ruby" }, as: :json
    assert_response :success
    assert_equal "Ruby", Geek.find(id).stack

    apply = Apply.create!(job: @job, geek: Geek.find(id))
    delete "/v1/geeks/#{id}"
    assert_response :no_content
    assert_not Geek.exists?(id)
    assert_not Apply.exists?(apply.id)
  end

  test "resume can be attached as text" do
    put "/v1/geeks/#{@geek.id}/resume", params: { resume: "Ruby developer with Rails experience" }, as: :json

    assert_response :success
    assert_equal "Ruby developer with Rails experience", @geek.reload.resume
  end

  test "applies can be created edited and deleted" do
    post "/v1/applies", params: { job_id: @job.id, geek_id: @other_geek.id }, as: :json
    assert_response :created
    id = response.parsed_body["id"]
    assert_equal false, response.parsed_body["read"]

    patch "/v1/applies/#{id}", params: { read: true, invited: true }, as: :json
    assert_response :success
    assert Apply.find(id).invited?

    delete "/v1/applies/#{id}"
    assert_response :no_content
    assert_not Apply.exists?(id)
  end

  test "nested apply creation uses the job from the route" do
    post "/v1/jobs/#{@job.id}/applies",
      params: { job_id: @other_job.id, geek_id: @other_geek.id }, as: :json

    assert_response :created
    assert_equal @job.id, response.parsed_body["job_id"]
  end

  test "applies can be filtered by true and false states" do
    get "/v1/applies", params: { read: "false", invited: "false" }
    assert_equal [@other_apply.id], response.parsed_body.map { |item| item["id"] }

    get "/v1/geeks/#{@geek.id}/applies", params: { read: "true", invited: "true" }
    assert_equal [@apply.id], response.parsed_body.map { |item| item["id"] }

    get "/v1/applies", params: { read: "true", invited: "false" }
    assert_equal [], response.parsed_body
  end

  test "invalid boolean values are rejected" do
    get "/v1/applies", params: { read: "perhaps" }
    assert_response :bad_request

    patch "/v1/applies/#{@apply.id}", params: { invited: "perhaps" }, as: :json
    assert_response :bad_request
    assert @apply.reload.invited?
  end

  test "identifier filters reject arrays and objects with JSON 400" do
    {
      "/v1/jobs" => { company_id: @company.id },
      "/v1/applies" => { company_id: @company.id, job_id: @job.id, geek_id: @geek.id },
      "/v1/geeks" => { company_id: @company.id, job_id: @job.id }
    }.each do |path, filters|
      filters.each do |field, id|
        [[id], { value: id }].each do |value|
          get path, params: { field => value }

          assert_response :bad_request
          assert_equal "application/json", response.media_type
          assert_equal "#{field} must be a scalar identifier", response.parsed_body["error"]
        end
      end
    end
  end

  test "query string arrays are rejected in identifier filters" do
    get "/v1/jobs?company_id[]=#{@company.id}"
    assert_response :bad_request

    get "/v1/applies?job_id[]=#{@job.id}"
    assert_response :bad_request

    get "/v1/geeks?job_id[]=#{@job.id}"
    assert_response :bad_request
  end

  test "nested apply creation rejects a structured company filter" do
    assert_no_difference "Apply.count" do
      post "/v1/jobs/#{@job.id}/applies",
        params: { company_id: [@company.id], geek_id: @geek.id }, as: :json
    end

    assert_response :bad_request
    assert_equal "company_id must be a scalar identifier", response.parsed_body["error"]
  end

  test "company and job applicants and applies are available" do
    [
      ["/v1/companies/#{@company.id}/geeks", @geek.id],
      ["/v1/jobs/#{@job.id}/geeks", @geek.id],
      ["/v1/companies/#{@company.id}/jobs/#{@job.id}/geeks", @geek.id],
      ["/v1/companies/#{@company.id}/applies", @apply.id],
      ["/v1/jobs/#{@job.id}/applies", @apply.id],
      ["/v1/companies/#{@company.id}/jobs/#{@job.id}/applies", @apply.id]
    ].each do |path, id|
      get path
      assert_response :success
      assert_equal [id], response.parsed_body.map { |item| item["id"] }
    end
  end

  test "read and invite actions update apply status" do
    put "/v1/applies/#{@other_apply.id}/read"
    assert_response :success
    assert @other_apply.reload.read?
    assert_not @other_apply.invited?

    put "/v1/applies/#{@other_apply.id}/invite"
    assert_response :success
    assert @other_apply.reload.invited?
  end

  test "deleted jobs remain in the database and disappear from API" do
    delete "/v1/jobs/#{@job.id}"
    assert_response :no_content
    assert @job.reload.deleted?
    assert Apply.exists?(@apply.id)

    get "/v1/jobs/#{@job.id}"
    assert_response :not_found
    get "/v1/jobs"
    assert_not_includes response.parsed_body.map { |item| item["id"] }, @job.id

    post "/v1/applies", params: { job_id: @job.id, geek_id: @other_geek.id }, as: :json
    assert_response :unprocessable_entity
  end

  test "deleted companies retain jobs and disappear from API" do
    delete "/v1/companies/#{@company.id}"
    assert_response :no_content
    assert @company.reload.deleted?
    assert Job.exists?(@job.id)

    get "/v1/companies"
    assert_not_includes response.parsed_body.map { |item| item["id"] }, @company.id
    get "/v1/jobs"
    assert_not_includes response.parsed_body.map { |item| item["id"] }, @job.id

    post "/v1/jobs", params: { name: "Node", place: "Remote", company_id: @company.id }, as: :json
    assert_response :unprocessable_entity
  end

  test "mark deleted route sets the company flag" do
    put "/v1/companies/#{@company.id}/mark_deleted"

    assert_response :success
    assert_equal true, response.parsed_body["deleted"]
    assert @company.reload.deleted?

    put "/v1/companies/#{@company.id}/mark_deleted"
    assert_response :success
    assert_equal true, response.parsed_body["deleted"]
  end

  test "missing records and unknown routes return JSON 404" do
    get "/v1/companies/999999999"
    assert_response :not_found
    assert_equal "not_found", response.parsed_body["status"]

    get "/unknown/path"
    assert_response :not_found
    assert_equal "application/json", response.media_type
    assert_equal "no_route", response.parsed_body["status"]
  end

  test "invalid input returns validation errors without creating records" do
    assert_no_difference "Job.count" do
      post "/v1/jobs", params: { name: "Node", place: "Remote" }, as: :json
    end
    assert_response :unprocessable_entity
    assert response.parsed_body["errors"].key?("company")

    post "/v1/companies", params: { location: "London" }, as: :json
    assert_response :unprocessable_entity
    assert response.parsed_body["errors"].key?("name")
  end
end

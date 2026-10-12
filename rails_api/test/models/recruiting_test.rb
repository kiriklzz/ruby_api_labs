require "test_helper"

class RecruitingTest < ActiveSupport::TestCase
  setup do
    @company = Company.create!(name: "MoGo", location: "New York")
    @job = @company.jobs.create!(name: "Ruby developer", place: "Remote")
    @geek = Geek.create!(name: "Mike", stack: "Ruby")
  end

  test "companies and geeks are connected through jobs and applies" do
    apply = Apply.create!(job: @job, geek: @geek)

    assert_equal @company, apply.job.company
    assert_equal [@job], @company.jobs.to_a
    assert_equal [apply], @geek.applies.to_a
    assert_equal [@geek], @job.geeks.to_a
    assert_equal [@job], @geek.jobs.to_a
  end

  test "required fields cannot be blank" do
    [Company.new, Job.new, Geek.new, Apply.new].each do |record|
      assert_not record.valid?, record.class.name
    end
  end

  test "job must refer to an existing company" do
    @job.company_id = Company.maximum(:id) + 1

    assert_not @job.valid?
    assert @job.errors[:company].present?
  end

  test "apply must refer to an existing geek and job" do
    apply = Apply.new(job_id: Job.maximum(:id) + 1, geek_id: Geek.maximum(:id) + 1)

    assert_not apply.valid?
    assert apply.errors[:job].present?
    assert apply.errors[:geek].present?
  end

  test "false is a valid initial state for apply" do
    apply = Apply.create!(job: @job, geek: @geek)

    assert_equal false, apply.read
    assert_equal false, apply.invited
    apply.read = nil
    assert_not apply.valid?
    apply.read = false
    apply.invited = nil
    assert_not apply.valid?
  end

  test "name longer than 255 characters is rejected" do
    @company.name = "a" * 256

    assert_not @company.valid?
    assert @company.errors[:name].present?
  end
end

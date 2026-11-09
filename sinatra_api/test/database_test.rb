ENV['RACK_ENV'] = 'test'
require 'minitest/autorun'
require_relative '../config/database'
Dir[File.expand_path('../models/*.rb', __dir__)].sort.each { |file| require file }

class DatabaseTest < Minitest::Test
  def test_associations_and_serialization
    DB.transaction(rollback: :always) do
      company = Company.create(name: 'Test', location: 'London')
      job = Job.create(name: 'Ruby', place: 'Remote', company: company)
      geek = Geek.create(name: 'Mike', stack: 'Ruby')
      apply = Apply.create(job: job, geek: geek)
      assert_equal [job.id], company.jobs.map(&:id)
      assert_equal company.id, job.company.id
      assert_equal [apply.id], geek.applies.map(&:id)
      assert_equal false, apply.to_api[:read]
      assert_equal [:id, :name, :location].sort, company.to_api.keys.sort
      assert job.created_at
      assert_raises(Sequel::ForeignKeyConstraintViolation) do
        DB.transaction(savepoint: true) { DB[:jobs].insert(name: 'Bad', place: 'Remote', company_id: -1) }
      end
    end
  end
end

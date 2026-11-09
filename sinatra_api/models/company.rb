class Company < Sequel::Model
  plugin :timestamps, update_on_create: true
  plugin :validation_helpers
  one_to_many :jobs

  dataset_module do
    def by_name(name)
      where(Sequel.ilike(:name, "%#{escape_like(name)}%"))
    end

    def by_location(location)
      where(Sequel.ilike(:location, "%#{escape_like(location)}%"))
    end
  end

  def self.company_jobs(name)
    Job.where(company_id: by_name(name).select(:id))
  end

  def validate
    super
    validates_presence [:name, :location]
  end

  def to_api
    values.slice(:id, :name, :location)
  end
end

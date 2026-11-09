class Company < Sequel::Model
  plugin :timestamps, update_on_create: true
  plugin :validation_helpers
  one_to_many :jobs

  def validate
    super
    validates_presence [:name, :location]
  end

  def to_api
    values.slice(:id, :name, :location)
  end
end

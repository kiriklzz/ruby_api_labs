class Job < Sequel::Model
  plugin :timestamps, update_on_create: true
  many_to_one :company
  one_to_many :applies

  def to_api
    values.slice(:id, :name, :place, :company_id)
  end
end

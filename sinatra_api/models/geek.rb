class Geek < Sequel::Model
  plugin :timestamps, update_on_create: true
  one_to_many :applies

  def to_api
    values.slice(:id, :name, :stack, :resume)
  end
end

class Job < Sequel::Model
  plugin :timestamps, update_on_create: true
  many_to_one :company
  one_to_many :applies

  dataset_module do
    def by_name(name)
      where(Sequel.ilike(:name, "%#{escape_like(name)}%"))
    end

    def by_place(place)
      where(Sequel.ilike(:place, "%#{escape_like(place)}%"))
    end
  end

  def to_api
    values.slice(:id, :name, :place, :company_id)
  end
end

class Apply < Sequel::Model(:applies)
  plugin :timestamps, update_on_create: true
  many_to_one :job
  many_to_one :geek

  dataset_module do
    def read
      where(read: true)
    end

    def unread
      where(read: false)
    end
  end

  def to_api
    values.slice(:id, :read, :invited, :job_id, :geek_id)
  end
end

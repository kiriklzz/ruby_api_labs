class Apply < Sequel::Model(:applies)
  plugin :timestamps, update_on_create: true
  many_to_one :job
  many_to_one :geek

  def to_api
    values.slice(:id, :read, :invited, :job_id, :geek_id)
  end
end

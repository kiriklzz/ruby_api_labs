Sequel.migration do
  change do
    create_table(:applies) do
      primary_key :id
      foreign_key :job_id, :jobs, null: false, index: true
      foreign_key :geek_id, :geeks, null: false, index: true
      TrueClass :read, default: false, null: false
      TrueClass :invited, default: false, null: false
      DateTime :created_at
      DateTime :updated_at
    end
  end
end

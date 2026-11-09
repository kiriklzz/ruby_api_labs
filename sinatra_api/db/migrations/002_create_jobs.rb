Sequel.migration do
  change do
    create_table(:jobs) do
      primary_key :id
      String :name, null: false
      String :place, null: false
      foreign_key :company_id, :companies, null: false, index: true
      DateTime :created_at
      DateTime :updated_at
    end
  end
end

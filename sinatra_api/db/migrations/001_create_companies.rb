Sequel.migration do
  change do
    create_table(:companies) do
      primary_key :id
      String :name, null: false
      String :location, null: false
      DateTime :created_at
      DateTime :updated_at
    end
  end
end

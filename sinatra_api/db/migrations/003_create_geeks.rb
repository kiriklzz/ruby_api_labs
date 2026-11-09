Sequel.migration do
  change do
    create_table(:geeks) do
      primary_key :id
      String :name, null: false
      String :stack, null: false
      TrueClass :resume, default: false, null: false
      DateTime :created_at
      DateTime :updated_at
    end
  end
end

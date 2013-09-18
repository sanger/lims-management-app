::Sequel.migration do
  change do
    create_table :primary_keys do
      primary_key :id
      String :table_name
      Integer :current_key
    end
  end
end

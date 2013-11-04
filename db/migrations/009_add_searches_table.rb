Sequel.migration do
  change do
    create_table :searches do
      primary_key :id
      String :description
      String :filter_type
      String :model
      blob :filter_parameters
    end
  end
end

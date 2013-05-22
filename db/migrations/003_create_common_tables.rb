Sequel.migration do
  change do
    # uuid resources (only if does not exist yet)
    create_table? :uuid_resources do
      primary_key :id
      String :uuid, :fixed => true, :size => 64
      String :model_class
      Integer :key
    end
  end
end

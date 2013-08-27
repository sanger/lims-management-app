Sequel.migration do
  change do
    alter_table :uuid_resources do
      add_index :uuid
      add_index [:key, :model_class]
    end
  end
end

Sequel.migration do
  change do
    alter_table :uuid_resources do
      add_index :uuid
      add_index [:model_class, :key]
    end
  end
end

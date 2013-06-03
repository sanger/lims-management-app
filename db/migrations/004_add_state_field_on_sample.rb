Sequel.migration do
  change do
    alter_table :samples do
      add_column :state, String
    end
  end
end

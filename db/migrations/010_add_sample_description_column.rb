::Sequel.migration do
  change do
    alter_table :samples do
      add_column :sample_description, String, :text => true
    end
  end
end

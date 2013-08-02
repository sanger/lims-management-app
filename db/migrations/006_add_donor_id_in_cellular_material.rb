Sequel.migration do
  change do
    alter_table :cellular_material do
      add_column :donor_id, String
    end
  end
end

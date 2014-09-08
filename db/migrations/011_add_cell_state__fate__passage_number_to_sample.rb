::Sequel.migration do
  change do
    alter_table :samples do
      add_column :cell_type,        String, :text => true
      add_column :growth_condition, String, :text => true
      add_column :time_point,       String, :text => true
    end
  end
end

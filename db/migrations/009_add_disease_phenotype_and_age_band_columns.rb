::Sequel.migration do
  change do
    alter_table :samples do
      add_column :disease_phenotype, String
      add_column :age_band, String
    end
  end
end

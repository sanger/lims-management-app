Sequel.migration do
  change do
    create_table :taxonomies do
      primary_key :id
      foreign_key :overrides_id, :taxonomies, :key => :id
      Integer :taxon_id
      String :name
      String :type
      Date :created
      Date :deleted
    end

    add_index :taxonomies, :taxon_id

    alter_table :samples do
      add_column :common_taxon_id, Integer
      rename_column :taxon_id, :scientific_taxon_id
    end
  end
end

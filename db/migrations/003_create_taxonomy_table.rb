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
      drop_column :taxon_id
      drop_column :common_name
      add_foreign_key :common_taxon_id, :taxonomies, :key => :id
      add_foreign_key :scientific_taxon_id, :taxonomies, :key => :id
    end
  end
end

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

    create_table :tmp_taxonomies do
      primary_key :id
      Integer :taxon_id
      String :name
      String :type
    end

    alter_table :samples do
      add_column :common_taxon_id, Integer
      rename_column :taxon_id, :scientific_taxon_id
    end
  end
end

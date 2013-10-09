Sequel.migration do
  change do
    create_table :collections do
      primary_key :id
      String :type, :null => false
      index :type
    end

    create_table :collection_data_string do
      primary_key :id
      foreign_key :collection_id, :collections, :key => :id
      String :key
      String :value
      index [:key, :collection_id], :unique => true
    end

    create_table :collection_data_bool do
      primary_key :id
      foreign_key :collection_id, :collections, :key => :id
      String :key
      TrueClass :value
      index [:key, :collection_id], :unique => true
    end

    create_table :collection_data_int do
      primary_key :id
      foreign_key :collection_id, :collections, :key => :id
      String :key
      Integer :value
      index [:key, :collection_id], :unique => true
    end

    create_table :collection_data_url do
      primary_key :id
      foreign_key :collection_id, :collections, :key => :id
      String :key
      String :value
      index [:key, :collection_id], :unique => true
    end

    create_table :collection_data_uuid do
      primary_key :id
      foreign_key :collection_id, :collections, :key => :id
      String :key
      String :value, :fixed => true, :size => 64
      index [:key, :collection_id], :unique => true
    end

    create_table :collections_samples do
      primary_key :id
      foreign_key :collection_id, :collections, :key => :id
      foreign_key :sample_id, :samples, :key => :id
      index [:collection_id, :sample_id], :unique => true
    end
  end
end

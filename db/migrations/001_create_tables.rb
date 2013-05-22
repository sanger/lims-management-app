Sequel.migration do

  change do
    # dna
    create_table :dna do
      primary_key :id
      Bool :pre_amplified
      DateTime :date_of_sample_extraction
      String :extraction_method
      Integer :concentration
      Bool :sample_purified
      String :concentration_determined_by_which_method
    end

    # rna
    create_table :rna do
      primary_key :id
      Bool :pre_amplified
      DateTime :date_of_sample_extraction
      String :extraction_method
      Integer :concentration
      Bool :sample_purified
      String :concentration_determined_by_which_method
    end

    # genotyping
    create_table :genotyping do
      primary_key :id
      String :country_of_origin
      String :geographical_region
      String :ethnicity
    end

    # cellular material
    create_table :cellular_material do
      primary_key :id
      Bool :lysed
    end

    # Samples
    create_table :samples do
      primary_key :id
      foreign_key :dna_id, :dna, :key => :id
      foreign_key :rna_id, :rna, :key => :id
      foreign_key :cellular_material_id, :cellular_material, :key => :id
      foreign_key :genotyping_id, :genotyping, :key => :id
      String :hmdmc_number
      String :supplier_sample_name
      String :common_name
      Integer :taxon_id
      String :gender
      String :sanger_sample_id
      String :sample_type
      String :ebi_accession_number
      Integer :volume
      String :sample_source
      DateTime :date_of_sample_collection
      Bool :is_sample_a_control
      Bool :is_re_submitted_sample
      String :mother
      String :father
      String :sibling
      String :gc_content
      String :public_name
      String :cohort
      String :storage_conditions

      unique :sanger_sample_id
    end
  end
end

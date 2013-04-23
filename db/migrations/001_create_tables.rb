Sequel.migration do

  change do
    # Samples
    create_table :samples do
      primary_key :internal_id
      foreign_key :dna_id, :dna, :key => :internal_id
      foreign_key :rna_id, :rna, :key => :internal_id
      foreign_key :cellular_material_id, :cellular_material, :key => :internal_id
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

    # genotyping_studies
    create_table :genotyping_studies do
      primary_key :internal_id
      String :country_of_origin
      String :geographical_region
      String :ethnicity
    end

    # cellular material
    create_table :cellular_material do
      primary_key :internal_id
      Bool :lysed
    end

    # dna
    create_table :dna do
      primary_key :internal_id
      Bool :pre_amplified
      DateTime :date_of_sample_extraction
      String :extraction_method
      Integer :concentration
      Bool :sample_purified
      String :concentration_determined_by_which_method
    end

    # rna
    create_table :rna do
      primary_key :internal_id
      Bool :pre_amplified
      DateTime :date_of_sample_extraction
      String :extraction_method
      Integer :concentration
      Bool :sample_purified
      String :concentration_determined_by_which_method
    end

    # uuid resources
    create_table :uuid_resources do
      primary_key :internal_id
      String :uuid, :fixed => true, :size => 64
      String :model_class
      Integer :key
    end
  end
end

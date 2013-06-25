require 'lims-management-app/sample/sample'

module Lims::ManagementApp
  shared_context "sample factory" do
    include_context "timecop"

    def new_common_sample
      Sample.new(common_sample_parameters)
    end
    
    def new_sample_with_dna
      sample = new_common_sample
      sample.dna = dna
      sample
    end

    def new_sample_with_rna
      sample = new_common_sample
      sample.rna = rna
      sample
    end

    def new_sample_with_cellular_material
      sample = new_common_sample
      sample.cellular_material = cellular_material
      sample
    end

    def new_sample_with_genotyping
      sample = new_common_sample
      sample.genotyping = genotyping
      sample
    end

    def new_sample_with_dna_rna_cellular
      sample = new_common_sample
      sample.dna = dna
      sample.rna = rna
      sample.cellular_material = cellular_material
      sample
    end

    def new_full_sample
      sample = new_common_sample
      sample.dna = dna
      sample.rna = rna
      sample.cellular_material = cellular_material
      sample.genotyping = genotyping
      sample
    end

    def dna
      Sample::Dna.new(dna_parameters)
    end

    def rna
      Sample::Rna.new(rna_parameters)
    end

    def cellular_material
      Sample::CellularMaterial.new(cellular_material_parameters)
    end

    def genotyping
      Sample::Genotyping.new(genotyping_parameters)
    end

    def common_sample_parameters(parameters = {})
      {
        :hmdmc_number => "test", :supplier_sample_name => "test", :common_name => "human",
        :ebi_accession_number => "test", :sample_source => "test", :mother => "test", :father => "test",
        :sibling => "test", :gc_content => "test", :public_name => "test", :cohort => "test", 
        :storage_conditions => "test", :taxon_id => 9606, :scientific_name => "Homo sapiens",
        :gender => "male", :sample_type => "RNA", :volume => 1, :date_of_sample_collection => DateTime.now, 
        :is_sample_a_control => true, :is_re_submitted_sample => false
      }.merge(parameters)
    end

    def dna_parameters(parameters = {})
      {
        :pre_amplified => true,
        :date_of_sample_extraction => DateTime.now,
        :extraction_method => "method",
        :concentration => 100,
        :sample_purified => true,
        :concentration_determined_by_which_method => "method"
      }.merge(parameters)
    end

    def rna_parameters(parameters = {})
      {
        :pre_amplified => true,
        :date_of_sample_extraction => DateTime.now,
        :extraction_method => "method",
        :concentration => 100,
        :sample_purified => true,
        :concentration_determined_by_which_method => "method"
      }.merge(parameters)
    end

    def cellular_material_parameters(parameters = {})
      {
        :lysed => true,
        :donor_id => "donor id"
      }.merge(parameters)
    end

    def genotyping_parameters(parameters = {})
      {
        :country_of_origin => "United Kingdom",
        :geographical_region => "Cambridgeshire",
        :ethnicity => "english"
      }.merge(parameters)
    end

    def full_sample_parameters(parameters = {})
      common_sample_parameters.merge(
        {
          :dna => dna_parameters, 
          :rna => rna_parameters, 
          :cellular_material => cellular_material_parameters, 
          :genotyping => genotyping_parameters
        }
      )
    end

    def update_parameters(parameters)
      parameters.mash do |k,v|
        case v
        when DateTime then [k, DateTime.now.to_s]
        when TrueClass then [k, false]
        when FalseClass then [k, true]
        when Fixnum then k.to_s == "taxon_id" ? [k, v] : [k, v+1]
        when Hash then [k, update_parameters(v)]
        else 
          case k
          when :gender then [k, "Hermaphrodite"]
          when :sample_type then [k, "Blood"]
          when :common_name then [k, v]
          when :scientific_name then [k, v]
          else [k, "new #{v}"]
          end
        end
      end
    end
  end
end

module Lims::ManagementApp
  class Sample
    DRAFT_STATE = "draft"
    PUBLISHED_STATE = "published"
  end
end

require 'lims-core/resource'
require 'lims-management-app/sample/dna/dna'
require 'lims-management-app/sample/rna/rna'
require 'lims-management-app/sample/cellular_material/cellular_material'
require 'lims-management-app/sample/genotyping/genotyping'
require 'lims-management-app/sample/validation_shared'
require 'securerandom'

module Lims::ManagementApp
  class Sample
    include Lims::Core::Resource
    include ValidationShared
    include ValidationShared::CommonValidator

    # The attributes below are all strings and not required
    %w(state supplier_sample_name gender sanger_sample_id sample_type 
    scientific_name common_name hmdmc_number ebi_accession_number sample_source
    mother father sibling gc_content public_name cohort storage_conditions).each do |name|
      attribute :"#{name}", String, :required => false, :initializable => true
    end

    attribute :taxon_id, Numeric, :required => false, :initializable => true
    attribute :volume, Integer, :required => false, :initializable => true
    attribute :date_of_sample_collection, DateTime, :required => false, :initializable => true
    attribute :is_sample_a_control, Boolean, :required => false, :initializable => true
    attribute :is_re_submitted_sample, Boolean, :required => false, :initializable => true
    attribute :dna, Dna, :required => false, :initializable => true
    attribute :rna, Rna, :required => false, :initializable => true
    attribute :cellular_material, CellularMaterial, :required => false, :initializable => true
    attribute :genotyping, Genotyping, :required => false, :initializable => true

    def initialize(*args, &block)
      super
    end
  end
end

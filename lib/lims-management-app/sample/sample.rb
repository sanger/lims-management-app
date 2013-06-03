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

    # A sanger sample id is generated only if we create a new sample (then
    # there are no parameters) or if the sanger sample id is not already present.
    def initialize(*args, &block)
      parameters = args.first.rekey { |k| k.to_sym } if args.first
      generate_sanger_sample_id unless parameters.nil? || parameters[:sanger_sample_id]
      super
    end

    private

    def generate_sanger_sample_id
      @sanger_sample_id = SangerSampleID.generate
      self
    end

    module SangerSampleID
      # @param [String,Integer] unique identifier
      # @return [String]
      # Generate a new sanger sample id using the
      # unique identifier in parameter.
      # @example S2-521-ID
      def self.generate
        "S2-#{unique_identifier.to_s}"
      end

      def self.unique_identifier
        SecureRandom.uuid.gsub(/-/, "")
      end
    end
  end
end

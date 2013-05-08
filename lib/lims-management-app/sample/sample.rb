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

    # required attributes
    %w{supplier_sample_name common_name gender sanger_sample_id sample_type}.each do |name|
      attribute :"#{name}", String, :required => true, :initializable => true
    end
    attribute :taxon_id, Numeric, :required => true, :initializable => true

    # The attributes below are all strings, not required with a private writer
    %w(hmdmc_number ebi_accession_number sample_source
    mother father sibling gc_content public_name cohort storage_conditions).each do |name|
      attribute :"#{name}", String, :required => false, :initializable => true
    end

    attribute :volume, Integer, :required => false, :initializable => true
    attribute :date_of_sample_collection, DateTime, :required => false, :initializable => true
    attribute :is_sample_a_control, Boolean, :required => false, :initializable => true
    attribute :is_re_submitted_sample, Boolean, :required => false, :initializable => true
    attribute :dna, Dna, :required => false, :initializable => true
    attribute :rna, Rna, :required => false, :initializable => true
    attribute :cellular_material, CellularMaterial, :required => false, :initializable => true
    attribute :genotyping, Genotyping, :required => false, :initializable => true

    def initialize(*args, &block)
      parameters = args.first.rekey { |k| k.to_sym }
      generate_sanger_sample_id unless parameters[:sanger_sample_id]
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

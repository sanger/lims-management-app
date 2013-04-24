require 'lims-core/resource'
require 'securerandom'

module Lims::ManagementApp
  class Sample
    include Lims::Core::Resource

    # required attributes
    attribute :sanger_sample_id, String, :required => true, :writer => :private, :initializable => true
    attribute :gender, String, :required => true, :writer => :private, :initializable => true
    attribute :sample_type, String, :required => true, :writer => :private, :initializable => true

    # The attributes below are all strings, not required with a private writer
    %w(hmdmc_number supplier_sample_name common_name ebi_accession_number sample_source
    mother father sibling gc_content public_name cohort storage_conditions).each do |name|
      attribute :"#{name}", String, :required => false, :writer => :private, :initializable => true
    end

    attribute :taxon_id, Numeric, :required => false, :writer => :private, :initializable => true
    attribute :volume, Integer, :required => false, :writer => :private, :initializable => true
    attribute :date_of_sample_collection, DateTime, :required => false, :writer => :private, :initializable => true
    attribute :is_sample_a_control, Boolean, :required => false, :writer => :private, :initializable => true
    attribute :is_re_submitted_sample, Boolean, :required => false, :writer => :private, :initializable => true

    validates_with_method :ensure_gender_value
    validates_with_method :ensure_sample_type_value

    GENDER = ["Not applicable", "Male", "Female", "Mixed", "Hermaphrodite", "Unkown"]
    SAMPLE_TYPE = ["DNA Human", "DNA Pathogen", "RNA", "Blood", "Saliva", "Tissue Non-Tumour", "Tissue Tumour", "Pathogen"]

    def generate_sanger_sample_id
      @sanger_sample_id = SangerSampleID.generate
    end

    private

    # @return [Boolean]
    # Validate if gender value belongs to the gender enumeration
    # Case insensitive
    # TODO: for human samples, it must be something else than Not applicable and Unknown
    def ensure_gender_value
      GENDER.map(&:downcase).include?(gender.downcase) if gender
    end

    # @return [Boolean]
    # Validate if sample_type value belongs to the sample_type enumeration
    # Case insensitive
    def ensure_sample_type_value
      SAMPLE_TYPE.map(&:downcase).include?(sample_type.downcase) if sample_type
    end


    module SangerSampleID
      # @param [String,Integer] unique identifier
      # @return [String]
      # Generate a new sanger sample id using the
      # unique identifier in parameter.
      # @example S2-521-ID
      def self.generate
        "S2-#{unique_identifier.to_s}-ID"
      end

      def self.unique_identifier
        SecureRandom.hex(10)
      end
    end
  end
end


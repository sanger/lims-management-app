require 'lims-core/resource'

module Lims::ManagementApp
  class Sample
    include Lims::Core::Resource

    %w(hdmc_number supplier_sample_name common_name ebi_accession_number sample_source
    mother father sibling gc_content public_name cohort storage_conditions).each do |name|
      attribute :"#{name}", String, :required => false, :writer => :private
    end

    attribute :taxon_id, Numeric, :required => false, :writer => :private
    attribute :gender, String, :required => true, :writer => :private
    attribute :sanger_sample_id, String, :required => true, :writer => :private
    attribute :sample_type, String, :required => true, :writer => :private
    attribute :volumne, Numeric, :required => false, :writer => :private
    attribute :date_of_sample_collection, DateTime, :required => false, :writer => :private
    attribute :is_sample_a_control, Boolean, :required => false, :writer => :private
    attribute :is_re_submitted_sample, Boolean, :required => false, :writer => :private
    
  end
end


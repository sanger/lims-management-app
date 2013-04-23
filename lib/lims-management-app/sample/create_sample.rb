require 'lims-core/actions/action'
require 'lims-management-app/sample/sample'

module Lims::ManagementApp
  class Sample
    class CreateSample
      include Lims::Core::Actions::Action

      attribute :taxon_id, Numeric, :required => false, :writer => :private
      attribute :volume, Integer, :required => false, :writer => :private
      attribute :date_of_sample_collection, DateTime, :required => false, :writer => :private
      attribute :is_sample_a_control, Boolean, :required => false, :writer => :private
      attribute :is_re_submitted_sample, Boolean, :required => false, :writer => :private
      %w(hmdmc_number supplier_sample_name common_name ebi_accession_number sample_source
      mother father sibling gc_content public_name cohort storage_conditions).each do |name|
        attribute :"#{name}", String, :required => false, :writer => :private
      end
      
      # required attributes
      attribute :sanger_sample_id, String, :required => true, :writer => :private
      attribute :gender, String, :required => true, :writer => :private
      attribute :sample_type, String, :required => true, :writer => :private

      def _call_in_session(session)
        sample = Sample.new(self.attributes)
        session << sample
        {:sample => sample, :uuid => session.uuid_for!(sample)}
      end
    end

    Create = CreateSample
  end
end

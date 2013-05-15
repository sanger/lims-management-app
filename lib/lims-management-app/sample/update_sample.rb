require 'lims-core/actions/action'
require 'lims-management-app/sample/action_shared'
require 'lims-management-app/sample/validation_shared'

module Lims::ManagementApp
  class Sample
    class UpdateSample
      include Lims::Core::Actions::Action
      include ActionShared
      include ValidationShared

      attribute :sample, Sample, :required => true
      attribute :gender, String, :required => false
      attribute :sample_type, String, :required => false
      attribute :scientific_taxon_id, Numeric, :required => false
      attribute :supplier_sample_name, String, :required => false
      attribute :common_name, String, :required => false

      def _call_in_session(session)
        _update([sample], session)
      end
    end

    Update = UpdateSample
  end
end

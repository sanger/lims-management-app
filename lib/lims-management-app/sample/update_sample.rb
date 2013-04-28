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

      def _call_in_session(session)
        _update(session)                  
      end
    end

    Update = UpdateSample
  end
end

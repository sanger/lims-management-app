require 'lims-core/actions/action'
require 'lims-management-app/sample/sample'
require 'lims-management-app/sample/action_shared'
require 'lims-management-app/sample/validation_shared'

module Lims::ManagementApp
  class Sample
    class UpdateSample
      include Lims::Core::Actions::Action
      include ActionShared
      include ValidationShared
      include ValidationShared::CommonValidator

      attribute :sample, Sample, :required => true
      attribute :state, String, :required => false

      def _call_in_session(session)
        _update(sample, session)
      end
    end

    Update = UpdateSample
  end
end

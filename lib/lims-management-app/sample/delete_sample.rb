require 'lims-core/actions/action'
require 'lims-management-app/sample/action_shared'

module Lims::ManagementApp
  class Sample
    class DeleteSample
      include Lims::Core::Actions::Action
      include ActionShared

      attribute :sample, Sample, :required => true

      def _call_in_session(session)
        _delete(sample, session)
      end
    end

    Delete = DeleteSample
  end
end

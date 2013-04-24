require 'lims-core/actions/action'
require 'lims-management-app/sample/sample'
require 'lims-management-app/sample/create_action_shared'

module Lims::ManagementApp
  class Sample
    class CreateBulkSample
      include Lims::Core::Actions::Action
      include CreateActionShared

      def _call_in_session(session)
        _create(session)
      end
    end
  end
end

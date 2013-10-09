require 'lims-core/actions/action'
require 'lims-management-app/sample-collection/sample_collection'
require 'lims-management-app/sample-collection/action_shared'

module Lims::ManagementApp
  class SampleCollection
    class DeleteSampleCollection
      include Lims::Core::Actions::Action
      include ValidationShared
      include ActionShared

      attribute :sample_collection, SampleCollection, :required => true

      def _call_in_session(session)
        session.delete(sample_collection)
        {:sample_collection => sample_collection}
      end
    end

    Delete = DeleteSampleCollection
  end
end

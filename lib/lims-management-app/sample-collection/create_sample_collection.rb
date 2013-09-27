require 'lims-core/actions/action'
require 'lims-management-app/sample-collection/sample_collection'
require 'lims-management-app/sample-collection/action_shared'

module Lims::ManagementApp
  class SampleCollection
    class CreateSampleCollection
      include Lims::Core::Actions::Action
      include ValidationShared
      include ActionShared

      attribute :type, String, :required => true
      attribute :data, Array, :required => false, :default => []
      attribute :sample_uuids, Array, :required => false, :default => []
      validates_with_method :ensure_type_parameter
      validates_with_method :ensure_data_parameter

      def _call_in_session(session)
        collection = SampleCollection.new(:type => type, :data => prepared_data, :samples => prepared_samples(session))
        session << collection
        {:sample_collection => collection, :uuid => session.uuid_for!(collection)}
      end
    end

    Create = CreateSampleCollection
  end
end

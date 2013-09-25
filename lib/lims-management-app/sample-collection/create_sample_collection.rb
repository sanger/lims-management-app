require 'lims-core/actions/action'
require 'lims-management-app/sample_collection/sample_collection'

module Lims::ManagementApp
  class SampleCollection
    class CreateSampleCollection
      include Lims::Core::Actions::Action

      attribute :type, String, :required => true
      attribute :data, Array, :required => false, :default => []
      attribute :samples, Array, :required => false, :default => []

      def _call_in_session(session)
        collection = SampleCollection.new(:type => type, :data => data, :samples => samples)
        session << collection
        {:sample_collection => collection, :uuid => session.uuid_for!(collection)}
      end
    end

    Create = CreateSampleCollection
  end
end

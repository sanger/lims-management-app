require 'lims-core/persistence/filter'
require 'lims-core/resource'

module Lims::Core
  module Persistence
    class SampleCollectionFilter < Lims::Core::Persistence::Filter
      include Lims::Core::Resource

      attribute :criteria, Hash, :required => true

      def initialize(criteria)
        criteria = {:criteria => criteria} unless criteria.include?(:criteria)
        criteria[:criteria].rekey! { |k| k.to_sym }
        super(criteria)
      end

      def call(persistor)
        persistor.sample_collection_filter(criteria)
      end
    end

    class Persistor
      def sample_collection_filter(criteria)
        raise NotImplementedError, "sample_collection_filter needs to be implemented for subclass of Persistor"
      end
    end
  end
end

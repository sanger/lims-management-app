require 'lims-core/persistence/persistor'

module Lims::ManagementApp
  class Sample
    class Taxonomy
      class TaxonomyPersistor < Lims::Core::Persistence::Persistor
        Model = Sample::Taxonomy
      end
    end
  end
end

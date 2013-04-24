require 'lims-core/persistence/persistor'

module Lims::ManagementApp
  class Sample
    class SamplePersistor < Lims::Core::Persistence::Persistor
      Model = Sample

      def filter_attributes_on_save(attributes)
        attributes.mash do |k,v|
          case k
          when :dna then [:dna_id, @session.id_for!(v)]
          else [k,v]
          end
        end
      end

      def filter_attributes_on_load(attributes)
        attributes.mash do |k,v|
          case k
          when :dna_id then [:dna, @session.dna[v]]
          else [k,v]
          end
        end
      end
    end
  end
end

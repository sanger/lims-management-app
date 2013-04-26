require 'time'

module Lims::ManagementApp
  class Sample
    module CreateActionShared

      def self.included(klass)
        klass.class_eval do
          attribute :taxon_id, Numeric, :required => false
          attribute :volume, Integer, :required => false
          attribute :date_of_sample_collection, String, :required => false
          attribute :is_sample_a_control, Integer, :required => false
          attribute :is_re_submitted_sample, Integer, :required => false
          %w(hmdmc_number supplier_sample_name common_name ebi_accession_number sample_source
          mother father sibling gc_content public_name cohort storage_conditions).each do |name|
            attribute :"#{name}", String, :required => false
          end

          # required attributes
          attribute :gender, String, :required => true
          attribute :sample_type, String, :required => true

          attribute :dna, Hash, :required => false
          attribute :rna, Hash, :required => false
          attribute :cellular_material, Hash, :required => false
        end
      end
    
      def _create(session)
        attributes = filtered_attributes
        samples = []

        quantity = attributes[:quantity] ? attributes[:quantity] : 1
        quantity.times do
          sample = Sample.new(attributes)
          sample.generate_sanger_sample_id
          sample.dna = Dna.new(dna) if dna && dna.size > 0
          sample.rna = Rna.new(rna) if rna && rna.size > 0
          sample.cellular_material = CellularMaterial.new(cellular_material) if cellular_material && cellular_material.size > 0
          session << sample
          samples << {:sample => sample, :uuid => session.uuid_for!(sample)}
        end

        (quantity == 1) ? samples.last : {:samples => samples.map { |e| e[:sample] }}
      end

      private

      def filtered_attributes
        self.attributes.mash do |k,v|
          case k
          when :date_of_sample_collection then [k, Time.parse(v)] if v
          when :quantity then [k, v ? v : 1]
          else [k,v]
          end
        end
      end
    end
  end
end

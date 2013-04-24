require 'time'

module Lims::ManagementApp
  class Sample
    module CreateActionShared

      def self.included(klass)
        klass.class_eval do
          # If quantity is set to x, it creates x identical samples 
          # based on the given parameters.
          attribute :quantity, Numeric, :required => false, :writer => :private
          attribute :taxon_id, Numeric, :required => false, :writer => :private
          attribute :volume, Integer, :required => false, :writer => :private
          attribute :date_of_sample_collection, String, :required => false, :writer => :private
          attribute :is_sample_a_control, Integer, :required => false, :writer => :private
          attribute :is_re_submitted_sample, Integer, :required => false, :writer => :private
          %w(hmdmc_number supplier_sample_name common_name ebi_accession_number sample_source
          mother father sibling gc_content public_name cohort storage_conditions).each do |name|
            attribute :"#{name}", String, :required => false, :writer => :private
          end

          # required attributes
          attribute :gender, String, :required => true, :writer => :private
          attribute :sample_type, String, :required => true, :writer => :private

          validates_with_method :ensure_quantity_value
        end
      end
    
      def _create(session)
        attributes = filtered_attributes
        samples = []

        attributes[:quantity].times do
          sample = Sample.new(attributes)
          sample.generate_sanger_sample_id
          session << sample
          samples << {:sample => sample, :uuid => session.uuid_for!(sample)}
        end

        (attributes[:quantity] == 1) ? samples.last : {:samples => samples.map { |e| e[:sample] }}
      end

      private

      def ensure_quantity_value
        quantity ? quantity > 0 : true
      end

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


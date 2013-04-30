require 'time'

module Lims::ManagementApp
  class Sample
    module ActionShared

      ATTRIBUTES = {:taxon_id => Numeric, :volume => Integer, :date_of_sample_collection => String,
      :is_sample_a_control => Integer, :is_re_submitted_sample => Integer, :hmdmc_number => String,
      :supplier_sample_name => String, :common_name => String, :ebi_accession_number => String,
      :sample_source => String, :mother => String, :father => String, :sibling => String,
      :gc_content => String, :public_name => String, :cohort => String, :storage_conditions => String,
      :dna => Hash, :rna => Hash, :cellular_material => Hash}

      def self.included(klass)
        ATTRIBUTES.each do |name, type|
          klass.class_eval do
            attribute :"#{name}", type, :required => false
          end
        end
        #klass.class_eval do
        #  attribute :taxon_id, Numeric, :required => false
        #  attribute :volume, Integer, :required => false
        #  attribute :date_of_sample_collection, String, :required => false
        #  attribute :is_sample_a_control, Integer, :required => false
        #  attribute :is_re_submitted_sample, Integer, :required => false
        #  %w(hmdmc_number supplier_sample_name common_name ebi_accession_number sample_source
        #  mother father sibling gc_content public_name cohort storage_conditions).each do |name|
        #    attribute :"#{name}", String, :required => false
        #  end

        #  attribute :dna, Hash, :required => false
        #  attribute :rna, Hash, :required => false
        #  attribute :cellular_material, Hash, :required => false
        #end
      end
    
      def _create(sample_quantity, session)
        attributes = filtered_attributes
        samples = []

        sample_quantity.times do
          sample = Sample.new(attributes)
          sample.generate_sanger_sample_id
          sample.dna = Dna.new(dna) if dna && dna.size > 0
          sample.rna = Rna.new(rna) if rna && rna.size > 0
          sample.cellular_material = CellularMaterial.new(cellular_material) if cellular_material && cellular_material.size > 0
          session << sample
          samples << {:sample => sample, :uuid => session.uuid_for!(sample)}
        end

        (sample_quantity == 1) ? samples.first : {:samples => samples.map { |e| e[:sample] }}
      end


      def _update(samples, session)
        samples.each do |current_sample|
          filtered_attributes.each do |k,v|
            if is_a_sample_attribute(k) && v
              if v.is_a?(Hash)
                v.each do |component_key, component_value|
                  unless current_sample.send(k)
                    component = case k
                                when :dna then Dna.new
                                when :rna then Rna.new
                                when :cellular_material then CellularMaterial.new
                                end
                    current_sample.send("#{k}=", component)
                  end
                  current_sample.send(k).send("#{component_key}=", component_value) 
                end
              elsif
                current_sample.send("#{k}=", v)
              end
            end
          end
        end

        (samples.size == 1) ? {:sample => samples.first} : {:samples => samples}
      end

      private

      def is_a_sample_attribute(name)
        attributes = ATTRIBUTES.keys | [:gender, :sample_type]
        attributes.include?(name)
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

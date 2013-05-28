require 'time'

module Lims::ManagementApp
  class Sample
    module ActionShared

      ATTRIBUTES = {:volume => Integer, :date_of_sample_collection => String,
      :is_sample_a_control => Integer, :is_re_submitted_sample => Integer, :hmdmc_number => String,
      :ebi_accession_number => String, :sample_source => String, :mother => String, :father => String, 
      :sibling => String, :gc_content => String, :public_name => String, :cohort => String, 
      :storage_conditions => String, :dna => Hash, :rna => Hash, :cellular_material => Hash,
      :genotyping => Hash, :common_name => String}

      class SampleUuidNotFound < StandardError
      end

      class SangerSampleIdNotFound < StandardError
      end

      def self.included(klass)
        unless klass.to_s.downcase =~ /delete/
          ATTRIBUTES.each do |name, type|
            klass.class_eval do
              attribute :"#{name}", type, :required => false
            end
          end
        end
      end

      # @param [Integer] sample_quantity
      # @param [Session] session
      # @return [Hash]
      # Shared method for sample creation and bulk creation
      # Generate the sanger sample id, set the dna/rna/cellular material data
      # if requested.
      def _create(sample_quantity, session)
        attributes = filtered_attributes
        samples = []

        sample_quantity.times do
          sample = Sample.new(attributes)
          sample.dna = Dna.new(dna) if dna && dna.size > 0
          sample.rna = Rna.new(rna) if rna && rna.size > 0
          sample.cellular_material = CellularMaterial.new(cellular_material) if cellular_material && cellular_material.size > 0
          sample.genotyping = Genotyping.new(genotyping) if genotyping && genotyping.size > 0
          session << sample
          samples << {:sample => sample, :uuid => session.uuid_for!(sample)}
        end

        (sample_quantity == 1) ? samples.first : {:samples => samples.map { |e| e[:sample] }}
      end

      # @param [Array] samples
      # @param [Session] session
      # @return [Hash]
      # Shared method for sample update and bulk update.
      # If we want to update a sample with dna/rna/cellular data
      # and if the sample doesn't have a Dna/Rna/CellularMaterial 
      # object associated, we need to create it first.
      def _update(samples, session)
        samples.each do |current_sample|
          filtered_attributes.each do |k,v|
            if is_a_sample_attribute(k)
              next if v.nil? # test nil on v otherwise bug with boolean value
              if v.is_a?(Hash)
                v.each do |component_key, component_value|
                  unless current_sample.send(k)
                    component = case k
                                when :dna then Dna.new
                                when :rna then Rna.new
                                when :cellular_material then CellularMaterial.new
                                when :genotyping then Genotyping.new
                                end
                    current_sample.send("#{k}=", component)
                  end
                  current_sample.send(k).send("#{component_key}=", component_value) 
                end
              else
                current_sample.send("#{k}=", v)
              end
            end
          end
        end

        (samples.size == 1) ? {:sample => samples.first} : {:samples => samples}
      end

      # @param [Array] samples
      # @param [Session] session
      # @return [Hash]
      def _delete(samples, session)
        samples.each do |current_sample|
          session.delete(current_sample)
        end
        (samples.size == 1) ? {:sample => samples.first} : {:samples => samples}
      end

      private

      # @param [String] name
      # @return [Bool]
      # Return true if name is a specific parameter for a sample
      def is_a_sample_attribute(name)
        attributes = ATTRIBUTES.keys | [:gender, :sample_type, :scientific_name, :taxon_id, :supplier_sample_name]
        attributes.include?(name)
      end

      # @return [Hash]
      def filtered_attributes
        self.attributes.mash do |k,v|
          case k
          when :date_of_sample_collection then [k, Time.parse(v)] if v
          when :quantity then [k, v ? v : 1]
          else [k,v]
          end
        end
      end

      # @param [Session] session
      # @return [Array]
      # If sanger sample ids is set, load the sample objects
      # associated to the sample ids. Otherwise, load
      # the sample objects according to the sample uuids attribute.
      # If one sample id/uuid is invalid, the action fails.
      def load_samples(session)
        [].tap do |s|
          if sanger_sample_ids
            sanger_sample_ids.each do |id|
              sample_object = session.sample[{:sanger_sample_id => id}]
              raise SangerSampleIdNotFound, "Sanger sample id '#{id}' is invalid" unless sample_object
              s << sample_object 
            end
          else
            sample_uuids.each do |uuid|
              sample_object = session[uuid]
              raise SampleUuidNotFound, "Sample uuid '#{uuid}' is invalid" unless sample_object
              s << sample_object 
            end
          end
        end
      end
    end
  end
end

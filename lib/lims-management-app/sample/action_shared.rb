require 'time'

module Lims::ManagementApp
  class Sample
    module ActionShared

      # Only the attributes which are common to all actions and NOT required
      ATTRIBUTES = {:volume => Integer, :date_of_sample_collection => String,
      :is_sample_a_control => Integer, :is_re_submitted_sample => Integer, :hmdmc_number => String,
      :ebi_accession_number => String, :sample_source => String, :mother => String, :father => String, 
      :sibling => String, :gc_content => String, :public_name => String, :cohort => String, 
      :storage_conditions => String, :dna => Hash, :rna => Hash, :cellular_material => Hash,
      :genotyping => Hash, :common_name => String, :gender => String, :sample_type => String,
      :taxon_id => Numeric, :supplier_sample_name => String, :scientific_name => String}

      SampleUuidNotFound = Class.new(StandardError)
      SangerSampleIdNotFound = Class.new(StandardError)

      # Only for create, bulk create and update actions
      def self.included(klass)
        if klass.to_s.downcase =~ /::createsample|::bulkcreatesample|::update/
          ATTRIBUTES.each do |name, type|
            klass.class_eval do
              attribute :"#{name}", type, :required => false
            end
          end
        end
      end

      # @param [Session] session
      # @return [Hash]
      # Shared method for sample creation and bulk creation
      # Generate the sanger sample id, set the dna/rna/cellular material data
      # if requested.
      def _create(session, sample_attributes=nil)
        sample = Sample.new(filtered_attributes(sample_attributes))
        sample.dna = Dna.new(dna) if dna && dna.size > 0
        sample.rna = Rna.new(rna) if rna && rna.size > 0
        sample.cellular_material = CellularMaterial.new(cellular_material) if cellular_material && cellular_material.size > 0
        sample.genotyping = Genotyping.new(genotyping) if genotyping && genotyping.size > 0
        
        # TODO: to refactor when bulk_create_sample is not used anymore
        sanger_sample_id_core = sample_attributes[:sanger_sample_id_core] if sample_attributes
        sample.sanger_sample_id = generate_sanger_sample_id(sanger_sample_id_core, session)
        session << sample

        {:sample => sample, :uuid => session.uuid_for!(sample)}
      end

      # @param [String] Sanger sample id core
      # @param [Session] session
      # @return [String]
      def generate_sanger_sample_id(core, session)
        persistor = session.persistor_for(:sanger_sample_id_number)
        number = persistor.generate_new_number
        "#{core}-#{number.to_s}"
      end

      # @param [Array] samples
      # @param [Session] session
      # @return [Hash]
      # Shared method for sample update and bulk update.
      # If we want to update a sample with dna/rna/cellular data
      # and if the sample doesn't have a Dna/Rna/CellularMaterial 
      # object associated, we need to create it first.
      def _update(sample, parameters = nil, session)
        filtered_attributes(parameters).each do |k,v|
          if is_a_sample_attribute(k)
            next if v.nil? # using nil? and not only v otherwise bug when boolean
            if v.is_a?(Hash)
              v.each do |component_key, component_value|
                unless sample.send(k)
                  component = case k
                              when :dna then Dna.new
                              when :rna then Rna.new
                              when :cellular_material then CellularMaterial.new
                              when :genotyping then Genotyping.new
                              end
                  sample.send("#{k}=", component)
                end
                sample.send(k).send("#{component_key}=", component_value) 
              end
            else
              sample.send("#{k}=", v)
            end
          end
        end

        # If the sample state is updated to published, we need to
        # be sure that the sample data are valid. So, we validate
        # the sample here one more time, after it has been updated 
        # with the new parameter. If it's not valid, we raise an error.
        result = validate_published_data(sample)
        raise Lims::Core::Actions::Action::InvalidParameters, {:ensure_published_data => result[1]} unless result.first

        {:sample => sample}
      end

      # @param [Array] samples
      # @param [Session] session
      # @return [Hash]
      def _delete(samples, session)
        if samples.is_a?(Array)
          samples.each { |current_sample| session.delete(current_sample) }
        else
          session.delete(samples)
        end

        samples.is_a?(Array) ? {:samples => samples} : {:sample => samples}
      end

      private

      # @param [String] name
      # @return [Bool]
      # Return true if name is a specific parameter for a sample
      def is_a_sample_attribute(name)
        attributes = ATTRIBUTES.keys | [:state]
        attributes.include?(name)
      end

      # @param [Hash] unfiltered_attributes 
      # @return [Hash]
      def filtered_attributes(unfiltered_attributes = nil)
        unfiltered_attributes = self.attributes unless unfiltered_attributes
        unfiltered_attributes.rekey! { |k| k.to_sym }
        unfiltered_attributes.mash do |k,v|
          case k
          when :date_of_sample_collection then v ? [k, Time.parse(v.to_s)] : [k, v] 
          when :quantity then [k, v ? v : 1]
          else [k,v]
          end
        end
      end
    end
  end
end

module Lims::ManagementApp
  class Sample
    # The component module is used in Dna/Rna/CellularMaterial classes
    # as we don't want to make them behave like a Lims::Core::Resource.
    # In fact, they are only part of a sample.
    module Component
      def initialize(*args, &block)
        options = args.extract_options!.rekey { |k| k.to_sym }
        initializables = self.class.attributes.select { |a| a.options[:initializable] == true }
        initial_options = options.subset(initializables.map(&:name))
        set_attributes(initial_options)
      end
    end
  end
end

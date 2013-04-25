require 'common'

module Lims::ManagementApp
  class Sample
    class Dna
      include Virtus
      include Aequitas
      attribute :pre_amplified, Boolean, :required => false, :initializable => true
      attribute :date_of_sample_extraction, DateTime, :required => false, :initializable => true
      attribute :extraction_method, String, :required => false, :initializable => true
      attribute :concentration, Integer, :required => false, :initializable => true
      attribute :sample_purified, Boolean, :required => false, :initializable => true
      attribute :concentration_determined_by_which_method, String, :required => false, :initializable => true

      def initialize(*args, &block)
        options = args.extract_options!
        initializables = self.class.attributes.select { |a| a.options[:initializable] == true }
        initial_options = options.subset(initializables.map(&:name))
        set_attributes(initial_options)
      end
    end
  end
end

require 'lims-core/resource'

module Lims::ManagementApp
  class Sample
    module Component
      def self.included(klass)
        klass.const_set(:NOT_IN_ROOT, true) unless klass.const_defined?(:NOT_IN_ROOT)
        klass.class_eval do
          include Lims::Core::Resource
        end
      end
    end
  end
end

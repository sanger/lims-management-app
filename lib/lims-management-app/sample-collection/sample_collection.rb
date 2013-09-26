require 'lims-core/resource'
require 'lims-management-app/sample-collection/validation_shared'
require 'lims-management-app/sample-collection/data/data_types'

module Lims::ManagementApp
  class SampleCollection
    include Lims::Core::Resource
    include ValidationShared

    attribute :type, String, :required => true, :initializable => true
    attribute :samples, Array, :required => false, :default => [], :initializable => true, :writer => :private
    attribute :data, Array, :required => false, :default => [], :initializable => true, :writer => :private
    validates_with_method :ensure_samples_parameter

    def ensure_data_parameter
      data.each do |d|
        unless d.respond_to?(:key) && d.respond_to?(:value)
          return [false, "Data elements must be instance of SampleCollectionData classes"]
        end

        type = d.class.to_s.split("::").last.downcase
        check_type_value = ensure_data_parameter_value(type, d.value)
        return check_type_value unless check_type_value.first
      end
      [true]
    end

    def ensure_samples_parameter
      samples.each do |sample|
        unless sample.is_a?(Sample)
          return [false, "'#{sample.inspect}' is not a sample"]
        end
      end
      [true]
    end
  end
end


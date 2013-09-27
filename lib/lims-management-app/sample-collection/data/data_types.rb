require 'lims-core/resource'

module Lims::ManagementApp
  class SampleCollection
    # Define dynamically a resource class for each types
    # defined in DATA_TYPES. Each class contains key/value attributes.
    module SampleCollectionData
      include Virtus

      DATA_TYPE_STRING = "string"
      DATA_TYPE_INT = "int"
      DATA_TYPE_URL = "url"
      DATA_TYPE_UUID = "uuid"
      DATA_TYPE_BOOL = "bool"

      DATA_TYPES_DEFINITION = {
        DATA_TYPE_STRING => String,
        DATA_TYPE_BOOL => Boolean,
        DATA_TYPE_INT => Integer,
        DATA_TYPE_URL => String,
        DATA_TYPE_UUID => String
      }

      DATA_TYPES = DATA_TYPES_DEFINITION.keys 

      DATA_TYPES_DEFINITION.each do |name, ruby_type|
        self.class_eval <<-EOC
          class #{name.capitalize}
            include Lims::Core::Resource
            attribute :key, String, :required => true, :initializable => true
            attribute :value, #{ruby_type}, :required => true, :initializable => true
          end
        EOC
      end
    end
  end
end

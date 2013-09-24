require 'lims-core/resource'
require 'lims-management-app/sample-collection/validation_shared'

module Lims::ManagementApp
  class SampleCollection
    include Lims::Core::Resource
    include ValidationShared

    attribute :type, String, :required => true, :initializable => true
    attribute :data, Array, :required => false, :initializable => true

  end
end


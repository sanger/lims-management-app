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
  end
end


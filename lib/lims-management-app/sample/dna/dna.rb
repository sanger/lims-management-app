require 'lims-core/resource'

module Lims::ManagementApp
  class Sample
    class Dna
      include Lims::Core::Resource

      attribute :pre_amplified, Boolean, :required => false, :writer => :private, :initializable => true
      attribute :date_of_sample_extraction, DateTime, :required => false, :writer => :private, :initializable => true
      attribute :extraction_method, String, :required => false, :writer => :private, :initializable => true
      attribute :concentration, Integer, :required => false, :writer => :private, :initializable => true
      attribute :sample_purified, Boolean, :required => false, :writer => :private, :initializable => true
      attribute :concentration_determined_by_which_method, String, :required => false, :writer => :private, :initializable => true
    end
  end
end

require 'common'
require 'lims-management-app/sample/component'

module Lims::ManagementApp
  class Sample
    class Dna
      include Virtus
      include Aequitas
      include Sample::Component
      attribute :pre_amplified, Boolean, :required => false, :initializable => true
      attribute :date_of_sample_extraction, DateTime, :required => false, :initializable => true
      attribute :extraction_method, String, :required => false, :initializable => true
      attribute :concentration, Integer, :required => false, :initializable => true
      attribute :sample_purified, Boolean, :required => false, :initializable => true
      attribute :concentration_determined_by_which_method, String, :required => false, :initializable => true
    end
  end
end

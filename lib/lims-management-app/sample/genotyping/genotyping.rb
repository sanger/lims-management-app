require 'common'
require 'lims-management-app/sample/component'

module Lims::ManagementApp
  class Sample
    class Genotyping
      include Virtus
      include Aequitas
      include Sample::Component
      attribute :country_of_origin, String, :required => false, :initializable => true
      attribute :geographical_region, String, :required => false, :initializable => true
      attribute :ethnicity, String, :required => false, :initializable => true
    end
  end
end

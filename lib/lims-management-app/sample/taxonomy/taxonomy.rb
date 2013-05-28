require 'common'
require 'lims-management-app/sample/component'

module Lims::ManagementApp
  class Sample
    class Taxonomy
      include Virtus
      include Aequitas
      include Sample::Component
      attribute :taxon_id, Integer, :required => false, :initializable => true
      attribute :name, String, :required => false, :initializable => true
      attribute :type, String, :required => false, :initializable => true
    end
  end
end

require 'lims-core/actions/action'
require 'lims-management-app/sample/sample'

module Lims::ManagementApp
  class Sample
    class CreateSample
      include Lims::Core::Actions::Action
    end

    Create = CreateSample
  end
end

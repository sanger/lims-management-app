module Lims::ManagementApp
  module Configuration
    def self.set_sample_collection_configuration(options)
      options.each do |k,v|
        const_set(k.upcase, v)
      end
    end
  end
end


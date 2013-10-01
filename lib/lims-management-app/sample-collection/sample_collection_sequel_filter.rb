require 'lims-core/persistence/sequel/filters'
require 'lims-management-app/sample-collection/sample_collection_filter'

module Lims::Core
  module Persistence
    module Sequel::Filters
      include Virtus

      alias :multi_criteria_filter_old :multi_criteria_filter
      def multi_criteria_filter(criteria)
        multi_criteria_filter_old(expanded_criteria(criteria))
      end

      def expanded_criteria(criteria)
        {}.tap do |ce|
          if criteria.has_key?(:data)
            criteria.delete(:data).each do |data|
              key, value = data["key"], data["value"]
              type = type_discovery(value)
              ce["collection_data_#{type}".to_sym] = {"key" => key, "value" => value}
            end
          end
        end.merge(criteria)
      end

      # TODO: Move type discovery in data_types.rb and use it for sample collection creation
      def type_discovery(value)
        case value
        when Integer then "int"
        when TrueClass || FalseClass then "bool"
        when Lims::ManagementApp::SampleCollection::ValidationShared::VALID_URL_PATTERN then "url"
        when Lims::ManagementApp::SampleCollection::ValidationShared::VALID_UUID_PATTERN then "uuid"
        else "string"
        end
      end
     

      def sample_collection_filter(criteria)
        criteria = criteria[:sample_collection] if criteria.keys.first.to_s == "sample_collection"
        criteria.rekey! { |k| k.to_sym }

        sample_collection_persistor = @session.sample_collection.__multi_criteria_filter(expanded_criteria(criteria))
        sample_collection_dataset = sample_collection_persistor.dataset.join(
          :collections_samples, :collection_id => :collections__id
        )

        debugger
        self.class.new(self, dataset.join(sample_collection_dataset, :sample_id => :samples__id).qualify.distinct)
      end
    end
  end
end

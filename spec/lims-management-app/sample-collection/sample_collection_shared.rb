require 'lims-management-app/sample-collection/sample_collection'
require 'lims-management-app/sample-collection/data/data_types'
require 'lims-management-app/sample/sample_shared'

module Lims::ManagementApp
  shared_context "collection factory" do
    include_context "sample factory"

    def new_sample_collection
      SampleCollection.new(sample_collection_parameters)
    end

    def sample_collection_parameters(parameters = {})
      {
        :type => "Study",
        :data => [
          data("key_string", "string", "name"),
          data("key_int", "integer", 1),
          data("key_url", "url", "http://www.sanger.ac.uk"),
          data("key_bool", "bool", true),
          data("key_uuid", "uuid", "11111111-2222-3333-4444-555555555555")
        ],
        :samples => [new_full_sample, new_sample_with_dna, new_common_sample]
      }.merge(parameters)
    end

    def data(key, type, value)
      case type
      when "string" then SampleCollection::SampleCollectionData::String
      when "integer" then SampleCollection::SampleCollectionData::Int
      when "url" then SampleCollection::SampleCollectionData::Url
      when "bool" then SampleCollection::SampleCollectionData::Bool
      when "uuid" then SampleCollection::SampleCollectionData::Uuid
      end.new(:key => key, :value => value)
    end

  end
end

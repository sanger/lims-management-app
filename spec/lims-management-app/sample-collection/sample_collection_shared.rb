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

    def sample_collection_action_parameters(parameters = {})
      {
        :type => "Study",
        :data => sample_collection_action_data,
        :sample_uuids => sample_collection_action_sample_uuids
      }.merge(parameters)
    end

    def sample_collection_action_data
      [
        {"key" => "key_string", "type" => "string", "value" => "value"},
        {"key" => "key_int", "type" => "int", "value" => 1},
        {"key" => "key_url", "type" => "url", "value" => "http://www.sanger.ac.uk"},
        {"key" => "key_bool", "type" => "bool", "value" => true},
        {"key" => "key_uuid", "type" => "uuid", "value" => "11111111-2222-3333-4444-555555555555"}
      ]
    end

    def sample_collection_action_sample_uuids
      [
        "11111111-0000-0000-0000-111111111111",
        "11111111-0000-0000-0000-222222222222",
        "11111111-0000-0000-0000-333333333333"
      ] 
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

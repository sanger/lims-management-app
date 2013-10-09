require "integrations/requests/apiary/15_sample_collection_errors/spec_helper"
describe "update_a_sample_collection_with_data_type_mismatch", :sample_collection_errors => true do
  include_context "use core context service"
  it "update_a_sample_collection_with_data_type_mismatch" do
    sample = Lims::ManagementApp::Sample.new({
        "sanger_sample_id" => "S2-1",
        "gender" => "Male",
        "sample_type" => "RNA",
        "taxon_id" => 9606,
        "common_name" => "human",
        "scientific_name" => "homo sapiens"
    })
    
    sample2 = Lims::ManagementApp::Sample.new({
        "sanger_sample_id" => "S2-2",
        "gender" => "Male",
        "sample_type" => "RNA",
        "taxon_id" => 9606,
        "common_name" => "human",
        "scientific_name" => "homo sapiens"
    })
    
    sample3 = Lims::ManagementApp::Sample.new({
        "sanger_sample_id" => "S2-3",
        "gender" => "Female",
        "sample_type" => "RNA",
        "taxon_id" => 9606,
        "common_name" => "human",
        "scientific_name" => "homo sapiens"
    })
    
    collection = Lims::ManagementApp::SampleCollection.new({
      :type => "Study",
      :data => [
          Lims::ManagementApp::SampleCollection::SampleCollectionData::String.new(:key => "key_string", "value" => "value string"),
          Lims::ManagementApp::SampleCollection::SampleCollectionData::Bool.new(:key => "key_bool", "value" => true),
          Lims::ManagementApp::SampleCollection::SampleCollectionData::Uuid.new(:key => "key_uuid", "value" => "11111111-0000-0000-0000-000000000000"),
          Lims::ManagementApp::SampleCollection::SampleCollectionData::Url.new(:key => "key_url", "value" => "http=>//www.sanger.ac.uk"),
          Lims::ManagementApp::SampleCollection::SampleCollectionData::Int.new(:key => "key_int", "value" => 132)
      ],
      :samples => [sample, sample2]
    })
    
    save_with_uuid collection => [1,2,3,4,5], sample => [1,2,3,4,6], sample2 => [1,2,3,4,7], sample3 => [1,2,3,4,8]

    header('Accept', 'application/json')
    header('Content-Type', 'application/json')

    response = put "/11111111-2222-3333-4444-555555555555", <<-EOD
    {
    "data": [
        {
            "key": "key_bool",
            "value": 123
        },
        {
            "key": "new_key_string",
            "type": "string",
            "value": "new value string"
        }
    ],
    "sample_uuids": [
        "11111111-2222-3333-4444-666666666666",
        "11111111-2222-3333-4444-888888888888"
    ]
}
    EOD
    response.status.should == 500
    response.body.should match_json <<-EOD
    {
    "general": [
        "The type of 'key_bool' should be 'bool'. The value passed is 'int'"
    ]
}
    EOD

  end
end

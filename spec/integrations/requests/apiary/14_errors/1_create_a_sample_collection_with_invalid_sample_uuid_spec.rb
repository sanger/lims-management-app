require "integrations/requests/apiary/14_errors/spec_helper"
describe "create_a_sample_collection_with_invalid_sample_uuid", :errors => true do
  include_context "use core context service"
  it "create_a_sample_collection_with_invalid_sample_uuid" do
    sample = Lims::ManagementApp::Sample.new({
        "sanger_sample_id" => "S2-1",
        "gender" => "Male",
        "sample_type" => "RNA",
        "taxon_id" => 9606,
        "common_name" => "human",
        "scientific_name" => "homo sapiens"
    })
    
    save_with_uuid sample => [1,2,3,4,6]

    header('Accept', 'application/json')
    header('Content-Type', 'application/json')

    response = post "/sample_collections", <<-EOD
    {
    "sample_collection": {
        "type": "Study",
        "sample_uuids": [
            "11111111-2222-3333-4444-666666666666",
            "11111111-1234-5678-9012-111111111111"
        ],
        "data": [
            {
                "key": "key_string",
                "type": "string",
                "value": "value string"
            },
            {
                "key": "key_bool",
                "value": true
            },
            {
                "key": "key_bool2",
                "type": "bool",
                "value": false
            },
            {
                "key": "key_uuid",
                "type": "uuid",
                "value": "11111111-0000-0000-0000-000000000000"
            },
            {
                "key": "key_url",
                "value": "http://www.sanger.ac.uk"
            },
            {
                "key": "key_int",
                "type": "int",
                "value": 123
            }
        ]
    }
}
    EOD
    response.status.should == 500
    response.body.should match_json <<-EOD
    {
    "general": [
        "The sample '11111111-1234-5678-9012-111111111111' cannot be found"
    ]
}
    EOD

  end
end

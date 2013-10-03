require "integrations/requests/apiary/13_searches/spec_helper"
describe "search_for_a_sample_collection_by_type_and_data", :searches => true do
  include_context "use core context service"
  it "search_for_a_sample_collection_by_type_and_data" do


    collection1 = Lims::ManagementApp::SampleCollection.new({
      :type => "Study",
      :data => [
          Lims::ManagementApp::SampleCollection::SampleCollectionData::String.new(:key => "key_string", "value" => "value string"),
          Lims::ManagementApp::SampleCollection::SampleCollectionData::String.new(:key => "key_string2", "value" => "value string 2"),
          Lims::ManagementApp::SampleCollection::SampleCollectionData::Bool.new(:key => "key_bool", "value" => false),
          Lims::ManagementApp::SampleCollection::SampleCollectionData::Uuid.new(:key => "key_uuid", "value" => "11111111-0000-0000-0000-000000000000"),
          Lims::ManagementApp::SampleCollection::SampleCollectionData::Url.new(:key => "key_url", "value" => "http://www.sanger.ac.uk"),
          Lims::ManagementApp::SampleCollection::SampleCollectionData::Int.new(:key => "key_int", "value" => 132)
      ]
    })
    
    collection2 = Lims::ManagementApp::SampleCollection.new({
      :type => "User",
      :data => [
          Lims::ManagementApp::SampleCollection::SampleCollectionData::String.new(:key => "key_string", "value" => "value string 2"),
          Lims::ManagementApp::SampleCollection::SampleCollectionData::Bool.new(:key => "key_bool", "value" => true),
          Lims::ManagementApp::SampleCollection::SampleCollectionData::Uuid.new(:key => "key_uuid", "value" => "11111111-0000-0000-0000-111111111111"),
          Lims::ManagementApp::SampleCollection::SampleCollectionData::Url.new(:key => "key_url", "value" => "http://www.sanger.ac.uk"),
          Lims::ManagementApp::SampleCollection::SampleCollectionData::Int.new(:key => "key_int", "value" => 245)
      ]
    })
    
    save_with_uuid collection1 => [1,2,3,4,6], collection2 => [1,2,3,4,7]

    header('Accept', 'application/json')
    header('Content-Type', 'application/json')

    response = post "/searches", <<-EOD
    {
    "search": {
        "description": "search for a sample collection by type and data",
        "model": "sample_collection",
        "criteria": {
            "type": "Study",
            "data": {
                "key_bool": false,
                "key_string": "value string",
                "key_string2": "value string 2",
                "key_url": "http://www.sanger.ac.uk"
            }
        }
    }
}
    EOD
    response.status.should == 200
    response.body.should match_json <<-EOD
    {
    "search": {
        "actions": {
            "read": "http://example.org/11111111-2222-3333-4444-555555555555",
            "first": "http://example.org/11111111-2222-3333-4444-555555555555/page=1",
            "last": "http://example.org/11111111-2222-3333-4444-555555555555/page=-1"
        },
        "uuid": "11111111-2222-3333-4444-555555555555"
    }
}
    EOD


    header('Accept', 'application/json')
    header('Content-Type', 'application/json')

    response = get "/11111111-2222-3333-4444-555555555555/page=1"
    response.status.should == 200
    response.body.should match_json <<-EOD
    {
    "actions": {
        "read": "http://example.org/11111111-2222-3333-4444-555555555555/page=1",
        "first": "http://example.org/11111111-2222-3333-4444-555555555555/page=1",
        "last": "http://example.org/11111111-2222-3333-4444-555555555555/page=-1"
    },
    "size": 1,
    "sample_collections": [
        {
            "actions": {
                "read": "http://example.org/11111111-2222-3333-4444-666666666666",
                "create": "http://example.org/11111111-2222-3333-4444-666666666666",
                "update": "http://example.org/11111111-2222-3333-4444-666666666666",
                "delete": "http://example.org/11111111-2222-3333-4444-666666666666"
            },
            "uuid": "11111111-2222-3333-4444-666666666666",
            "type": "Study",
            "data": {
                "key_string": "value string",
                "key_string2": "value string 2",
                "key_bool": false,
                "key_int": 132,
                "key_url": "http://www.sanger.ac.uk",
                "key_uuid": "11111111-0000-0000-0000-000000000000"
            },
            "samples": [

            ]
        }
    ]
}
    EOD

  end
end

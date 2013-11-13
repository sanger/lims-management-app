require "integrations/requests/apiary/13_searches/spec_helper"
describe "search_for_a_sample_collection_by_data", :searches => true do
  include_context "use core context service"
  it "search_for_a_sample_collection_by_data" do


    collection1 = Lims::ManagementApp::SampleCollection.new({
      :type => "Study",
      :data => [
          Lims::ManagementApp::SampleCollection::SampleCollectionData::DataString.new(:key => "key_string", "value" => "value string"),
          Lims::ManagementApp::SampleCollection::SampleCollectionData::DataBool.new(:key => "key_bool", "value" => true),
          Lims::ManagementApp::SampleCollection::SampleCollectionData::DataBool.new(:key => "key_bool2", :value => false),
          Lims::ManagementApp::SampleCollection::SampleCollectionData::DataUrl.new(:key => "key_url", "value" => "http://www.sanger.ac.uk"),
          Lims::ManagementApp::SampleCollection::SampleCollectionData::DataInt.new(:key => "key_int", "value" => 245),
          Lims::ManagementApp::SampleCollection::SampleCollectionData::DataInt.new(:key => "key_int2", "value" => 300)
      ]
    })
    
    collection2 = Lims::ManagementApp::SampleCollection.new({
      :type => "User",
      :data => [
          Lims::ManagementApp::SampleCollection::SampleCollectionData::DataBool.new(:key => "key_bool2", :value => false),
          Lims::ManagementApp::SampleCollection::SampleCollectionData::DataUuid.new(:key => "key_uuid", "value" => "11111111-0000-0000-0000-111111111111"),
          Lims::ManagementApp::SampleCollection::SampleCollectionData::DataUrl.new(:key => "key_url", "value" => "http://www.sanger.ac.uk"),
          Lims::ManagementApp::SampleCollection::SampleCollectionData::DataInt.new(:key => "key_int", "value" => 245),
          Lims::ManagementApp::SampleCollection::SampleCollectionData::DataInt.new(:key => "key_int2", "value" => 300)
      ]
    })
    
    collection3 = Lims::ManagementApp::SampleCollection.new({
      :type => "User",
      :data => [
          Lims::ManagementApp::SampleCollection::SampleCollectionData::DataBool.new(:key => "key_bool", "value" => false),
          Lims::ManagementApp::SampleCollection::SampleCollectionData::DataUrl.new(:key => "key_url", "value" => "http://www.sanger.ac.uk"),
          Lims::ManagementApp::SampleCollection::SampleCollectionData::DataInt.new(:key => "key_int", "value" => 789)
      ]
    })
    
    save_with_uuid collection1 => [1,2,3,4,6], collection2 => [1,2,3,4,7], collection3 => [1,2,3,4,8]

    header('Accept', 'application/json')
    header('Content-Type', 'application/json')

    response = post "/searches", <<-EOD
    {
    "search": {
        "description": "search for a sample collection by data",
        "model": "sample_collection",
        "criteria": {
            "data": {
                "key_bool2": false,
                "key_int": 245,
                "key_int2": 300,
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
    "size": 2,
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
                "key_bool": true,
                "key_bool2": false,
                "key_int": 245,
                "key_int2": 300,
                "key_url": "http://www.sanger.ac.uk"
            },
            "samples": [

            ]
        },
        {
            "actions": {
                "read": "http://example.org/11111111-2222-3333-4444-777777777777",
                "create": "http://example.org/11111111-2222-3333-4444-777777777777",
                "update": "http://example.org/11111111-2222-3333-4444-777777777777",
                "delete": "http://example.org/11111111-2222-3333-4444-777777777777"
            },
            "uuid": "11111111-2222-3333-4444-777777777777",
            "type": "User",
            "data": {
                "key_bool2": false,
                "key_int": 245,
                "key_int2": 300,
                "key_url": "http://www.sanger.ac.uk",
                "key_uuid": "11111111-0000-0000-0000-111111111111"
            },
            "samples": [

            ]
        }
    ]
}
    EOD

  end
end

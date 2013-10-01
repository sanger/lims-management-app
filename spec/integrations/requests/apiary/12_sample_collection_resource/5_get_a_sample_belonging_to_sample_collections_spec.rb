require "integrations/requests/apiary/12_sample_collection_resource/spec_helper"
describe "get_a_sample_belonging_to_sample_collections", :sample_collection => true do
  include_context "use core context service"
  it "get_a_sample_belonging_to_sample_collections" do
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
    
    collection1 = Lims::ManagementApp::SampleCollection.new({
      :type => "Study",
      :data => [
          Lims::ManagementApp::SampleCollection::SampleCollectionData::String.new(:key => "key_string", "value" => "value string"),
          Lims::ManagementApp::SampleCollection::SampleCollectionData::Bool.new(:key => "key_bool", "value" => true),
          Lims::ManagementApp::SampleCollection::SampleCollectionData::Url.new(:key => "key_url", "value" => "http=>//www.sanger.ac.uk"),
          Lims::ManagementApp::SampleCollection::SampleCollectionData::Int.new(:key => "key_int", "value" => 132)
      ],
      :samples => [sample]
    })
    
    collection2 = Lims::ManagementApp::SampleCollection.new({
      :type => "User",
      :data => [
          Lims::ManagementApp::SampleCollection::SampleCollectionData::String.new(:key => "key_string", "value" => "value string 2"),
          Lims::ManagementApp::SampleCollection::SampleCollectionData::Bool.new(:key => "key_bool", "value" => false),
          Lims::ManagementApp::SampleCollection::SampleCollectionData::Uuid.new(:key => "key_uuid", "value" => "11111111-0000-0000-0000-000000000000"),
          Lims::ManagementApp::SampleCollection::SampleCollectionData::Int.new(:key => "key_int", "value" => 456)
      ],
      :samples => [sample, sample2]
    })
    
    save_with_uuid sample => [1,2,3,4,7], sample2 => [1,2,3,4,8], collection1 => [1,2,3,4,5], collection2 => [1,2,3,4,6]

    header('Accept', 'application/json')
    header('Content-Type', 'application/json')

    response = get "/11111111-2222-3333-4444-777777777777"
    #response.status.should == 200
    response.body.should match_json <<-EOD
    {
    "sample": {
        "actions": {
            "read": "http://example.org/11111111-2222-3333-4444-777777777777",
            "create": "http://example.org/11111111-2222-3333-4444-777777777777",
            "update": "http://example.org/11111111-2222-3333-4444-777777777777",
            "delete": "http://example.org/11111111-2222-3333-4444-777777777777"
        },
        "uuid": "11111111-2222-3333-4444-777777777777",
        "state": null,
        "supplier_sample_name": null,
        "gender": "Male",
        "sanger_sample_id": "S2-1",
        "sample_type": "RNA",
        "scientific_name": "Homo sapiens",
        "common_name": "human",
        "hmdmc_number": null,
        "ebi_accession_number": null,
        "sample_source": null,
        "mother": null,
        "father": null,
        "sibling": null,
        "gc_content": null,
        "public_name": null,
        "cohort": null,
        "storage_conditions": null,
        "taxon_id": 9606,
        "volume": null,
        "date_of_sample_collection": null,
        "is_sample_a_control": null,
        "is_re_submitted_sample": null,
        "sample_collections": [
            {
                "actions": {
                    "read": "http://example.org/11111111-2222-3333-4444-555555555555",
                    "create": "http://example.org/11111111-2222-3333-4444-555555555555",
                    "update": "http://example.org/11111111-2222-3333-4444-555555555555",
                    "delete": "http://example.org/11111111-2222-3333-4444-555555555555"
                },
                "uuid": "11111111-2222-3333-4444-555555555555",
                "type": "Study",
                "data": {
                    "key_string": "value string",
                    "key_bool": true,
                    "key_int": 132,
                    "key_url": "http=>//www.sanger.ac.uk"
                }
            },
            {
                "actions": {
                    "read": "http://example.org/11111111-2222-3333-4444-666666666666",
                    "create": "http://example.org/11111111-2222-3333-4444-666666666666",
                    "update": "http://example.org/11111111-2222-3333-4444-666666666666",
                    "delete": "http://example.org/11111111-2222-3333-4444-666666666666"
                },
                "uuid": "11111111-2222-3333-4444-666666666666",
                "type": "User",
                "data": {
                    "key_string": "value string 2",
                    "key_bool": false,
                    "key_int": 456,
                    "key_uuid": "11111111-0000-0000-0000-000000000000"
                }
            }
        ]
    }
}
    EOD

  end
end

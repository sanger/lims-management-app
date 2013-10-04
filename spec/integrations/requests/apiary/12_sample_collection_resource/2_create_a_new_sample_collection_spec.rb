require "integrations/requests/apiary/12_sample_collection_resource/spec_helper"
describe "create_a_new_sample_collection", :sample_collection => true do
  include_context "use core context service"
  it "create_a_new_sample_collection" do
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
    
    save_with_uuid sample => [1,2,3,4,6], sample2 => [1,2,3,4,7]

    header('Accept', 'application/json')
    header('Content-Type', 'application/json')

    response = post "/sample_collections", <<-EOD
    {
    "sample_collection": {
        "type": "Study",
        "sample_uuids": [
            "11111111-2222-3333-4444-666666666666",
            "11111111-2222-3333-4444-777777777777"
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
    response.status.should == 200
    response.body.should match_json <<-EOD
    {
    "sample_collection": {
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
            "key_bool2": false,
            "key_uuid": "11111111-0000-0000-0000-000000000000",
            "key_url": "http://www.sanger.ac.uk",
            "key_int": 123
        },
        "samples": [
            {
                "actions": {
                    "read": "http://example.org/11111111-2222-3333-4444-666666666666",
                    "create": "http://example.org/11111111-2222-3333-4444-666666666666",
                    "update": "http://example.org/11111111-2222-3333-4444-666666666666",
                    "delete": "http://example.org/11111111-2222-3333-4444-666666666666"
                },
                "uuid": "11111111-2222-3333-4444-666666666666",
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
                "is_re_submitted_sample": null
            },
            {
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
                "sanger_sample_id": "S2-2",
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
                "is_re_submitted_sample": null
            }
        ]
    }
}
    EOD

  end
end

require "integrations/requests/apiary/13_searches/spec_helper"
describe "search_for_sample_collections_by_type_data_sample_uuids", :searches => true do
  include_context "use core context service"
  it "search_for_sample_collections_by_type_data_sample_uuids" do


    sample1 = Lims::ManagementApp::Sample.new({
        "sanger_sample_id" => "S2-1",
        "gender" => "Male",
        "sample_type" => "RNA",
        "taxon_id" => 9606,
        "common_name" => "human",
        "scientific_name" => "homo sapiens"
    })
    
    sample2 = Lims::ManagementApp::Sample.new({
        "sanger_sample_id" => "S2-2",
        "gender" => "Female",
        "sample_type" => "RNA",
        "taxon_id" => 9606,
        "common_name" => "human",
        "scientific_name" => "homo sapiens"
    })
    
    sample3 = Lims::ManagementApp::Sample.new({
        "sanger_sample_id" => "S2-3",
        "gender" => "Male",
        "sample_type" => "RNA",
        "taxon_id" => 9606,
        "common_name" => "human",
        "scientific_name" => "homo sapiens"
    })
    
    collection1 = Lims::ManagementApp::SampleCollection.new({
      :type => "Study",
      :data => [
          Lims::ManagementApp::SampleCollection::SampleCollectionData::DataString.new(:key => "key_string", "value" => "value string"),
          Lims::ManagementApp::SampleCollection::SampleCollectionData::DataBool.new(:key => "key_bool", "value" => true),
          Lims::ManagementApp::SampleCollection::SampleCollectionData::DataUuid.new(:key => "key_uuid", "value" => "11111111-0000-0000-0000-000000000000"),
          Lims::ManagementApp::SampleCollection::SampleCollectionData::DataUrl.new(:key => "key_url", "value" => "http://www.sanger.ac.uk"),
          Lims::ManagementApp::SampleCollection::SampleCollectionData::DataInt.new(:key => "key_int", "value" => 132)
      ],
      :samples => [sample1, sample2]
    })
    
    collection2 = Lims::ManagementApp::SampleCollection.new({
      :type => "User",
      :data => [
          Lims::ManagementApp::SampleCollection::SampleCollectionData::DataString.new(:key => "key_string", "value" => "value string 2"),
          Lims::ManagementApp::SampleCollection::SampleCollectionData::DataBool.new(:key => "key_bool", "value" => false),
          Lims::ManagementApp::SampleCollection::SampleCollectionData::DataBool.new(:key => "key_bool2", "value" => true),
          Lims::ManagementApp::SampleCollection::SampleCollectionData::DataUuid.new(:key => "key_uuid", "value" => "11111111-0000-0000-0000-111111111111"),
          Lims::ManagementApp::SampleCollection::SampleCollectionData::DataUrl.new(:key => "key_url", "value" => "http://www.sanger.ac.uk"),
          Lims::ManagementApp::SampleCollection::SampleCollectionData::DataInt.new(:key => "key_int", "value" => 245)
      ],
      :samples => [sample2]
    })
    
    collection3 = Lims::ManagementApp::SampleCollection.new({
      :type => "User",
      :data => [
          Lims::ManagementApp::SampleCollection::SampleCollectionData::DataString.new(:key => "key_string", "value" => "value string 3"),
          Lims::ManagementApp::SampleCollection::SampleCollectionData::DataBool.new(:key => "key_bool", "value" => false),
          Lims::ManagementApp::SampleCollection::SampleCollectionData::DataBool.new(:key => "key_bool2", "value" => true),
          Lims::ManagementApp::SampleCollection::SampleCollectionData::DataUrl.new(:key => "key_url", "value" => "http://www.sanger.ac.uk"),
          Lims::ManagementApp::SampleCollection::SampleCollectionData::DataInt.new(:key => "key_int", "value" => 245),
          Lims::ManagementApp::SampleCollection::SampleCollectionData::DataInt.new(:key => "key_int2", "value" => 789)
      ],
      :samples => [sample1, sample2, sample3]
    })
    
    save_with_uuid({
      collection1 => [1,2,3,4,6], collection2 => [1,2,3,4,7], collection3 => [1,2,3,4,8],
      sample1 => [1,0,0,0,1], sample2 => [1,0,0,0,2], sample3 => [1,0,0,0,3]
    })

    header('Accept', 'application/json')
    header('Content-Type', 'application/json')

    response = post "/searches", <<-EOD
    {
    "search": {
        "description": "search for sample collections by type, data and sample uuids",
        "model": "sample_collection",
        "criteria": {
            "type": "User",
            "data": {
                "key_bool": false,
                "key_int2": 789
            },
            "sample_uuids": [
                "11111111-0000-0000-0000-111111111111",
                "11111111-0000-0000-0000-222222222222"
            ]
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
                "read": "http://example.org/11111111-2222-3333-4444-888888888888",
                "create": "http://example.org/11111111-2222-3333-4444-888888888888",
                "update": "http://example.org/11111111-2222-3333-4444-888888888888",
                "delete": "http://example.org/11111111-2222-3333-4444-888888888888"
            },
            "uuid": "11111111-2222-3333-4444-888888888888",
            "type": "User",
            "data": {
                "key_string": "value string 3",
                "key_bool": false,
                "key_bool2": true,
                "key_int": 245,
                "key_int2": 789,
                "key_url": "http://www.sanger.ac.uk"
            },
            "samples": [
                {
                    "actions": {
                        "read": "http://example.org/11111111-0000-0000-0000-222222222222",
                        "create": "http://example.org/11111111-0000-0000-0000-222222222222",
                        "update": "http://example.org/11111111-0000-0000-0000-222222222222",
                        "delete": "http://example.org/11111111-0000-0000-0000-222222222222"
                    },
                    "uuid": "11111111-0000-0000-0000-222222222222",
                    "state": null,
                    "supplier_sample_name": null,
                    "gender": "Female",
                    "sanger_sample_id": "S2-2",
                    "sample_type": "RNA",
                    "scientific_name": "Homo sapiens",
                    "common_name": "human",
                    "hmdmc_number": null,
                    "ebi_accession_number": null,
                    "sample_source": null,
                    "disease_phenotype": null,
                    "age_band": null,
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
                        "read": "http://example.org/11111111-0000-0000-0000-111111111111",
                        "create": "http://example.org/11111111-0000-0000-0000-111111111111",
                        "update": "http://example.org/11111111-0000-0000-0000-111111111111",
                        "delete": "http://example.org/11111111-0000-0000-0000-111111111111"
                    },
                    "uuid": "11111111-0000-0000-0000-111111111111",
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
                    "disease_phenotype": null,
                    "age_band": null,
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
                        "read": "http://example.org/11111111-0000-0000-0000-333333333333",
                        "create": "http://example.org/11111111-0000-0000-0000-333333333333",
                        "update": "http://example.org/11111111-0000-0000-0000-333333333333",
                        "delete": "http://example.org/11111111-0000-0000-0000-333333333333"
                    },
                    "uuid": "11111111-0000-0000-0000-333333333333",
                    "state": null,
                    "supplier_sample_name": null,
                    "gender": "Male",
                    "sanger_sample_id": "S2-3",
                    "sample_type": "RNA",
                    "scientific_name": "Homo sapiens",
                    "common_name": "human",
                    "hmdmc_number": null,
                    "ebi_accession_number": null,
                    "sample_source": null,
                    "mother": null,
                    "father": null,
                    "disease_phenotype": null,
                    "age_band": null,
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
    ]
}
    EOD

  end
end

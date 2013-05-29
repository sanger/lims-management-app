require "integrations/requests/apiary/11_sample_resource/spec_helper"
describe "bulk_update_sample", :sample => true do
  include_context "use core context service"
  before do
  Lims::ManagementApp::Sample::SangerSampleID.stub(:generate) do |a|
    @count ||= 0
    @count += 1
    "S2-test" << @count.to_s << "-ID"
  end
  end
  it "bulk_update_sample" do
    sample = Lims::ManagementApp::Sample.new({
        "gender" => "Male",
        "sample_type" => "RNA",
        "taxon_id" => 9606,
        "date_of_sample_collection" => "2013-04-25 10:27 UTC",
        "is_sample_a_control" => true,
        "is_re_submitted_sample" => false,
        "hmdmc_number" => "number",
        "supplier_sample_name" => "name",
        "common_name" => "human",
        "scientific_name" => "homo sapiens",
        "ebi_accession_number" => "number",
        "sample_source" => "source",
        "mother" => "mother",
        "father" => "father",
        "sibling" => "sibling",
        "gc_content" => "content",
        "public_name" => "name",
        "cohort" => "cohort",
        "storage_conditions" => "conditions"
    })
    
    sample2 = Lims::ManagementApp::Sample.new({
        "gender" => "Male",
        "sample_type" => "RNA",
        "taxon_id" => 9606,
        "date_of_sample_collection" => "2013-04-25 10:27 UTC",
        "is_sample_a_control" => true,
        "is_re_submitted_sample" => false,
        "hmdmc_number" => "number",
        "supplier_sample_name" => "name",
        "common_name" => "human",
        "scientific_name" => "homo sapiens",
        "ebi_accession_number" => "number",
        "sample_source" => "source",
        "mother" => "mother",
        "father" => "father",
        "sibling" => "sibling",
        "gc_content" => "content",
        "public_name" => "name",
        "cohort" => "cohort",
        "storage_conditions" => "conditions"
    })
    
    save_with_uuid sample => [1,2,3,4,5], sample2 => [1,2,3,4,6]

    header('Accept', 'application/json')
    header('Content-Type', 'application/json')

    response = post "/actions/bulk_update_sample", <<-EOD
    {
    "bulk_update_sample": {
        "updates": {
            "11111111-2222-3333-4444-555555555555": {
                "volume": 5000
            },
            "11111111-2222-3333-4444-666666666666": {
                "volume": 4000
            }
        }
    }
}
    EOD
    response.status.should == 200
    response.body.should match_json <<-EOD
    {
    "bulk_update_sample": {
        "actions": {
        },
        "user": "user",
        "application": "application",
        "result": {
            "samples": [
                {
                    "actions": {
                        "read": "http://example.org/11111111-2222-3333-4444-555555555555",
                        "create": "http://example.org/11111111-2222-3333-4444-555555555555",
                        "update": "http://example.org/11111111-2222-3333-4444-555555555555",
                        "delete": "http://example.org/11111111-2222-3333-4444-555555555555"
                    },
                    "uuid": "11111111-2222-3333-4444-555555555555",
                    "sanger_sample_id": "S2-test1-ID",
                    "gender": "Male",
                    "sample_type": "RNA",
                    "hmdmc_number": "number",
                    "supplier_sample_name": "name",
                    "common_name": "human",
                    "scientific_name": "Homo sapiens",
                    "ebi_accession_number": "number",
                    "sample_source": "source",
                    "mother": "mother",
                    "father": "father",
                    "sibling": "sibling",
                    "gc_content": "content",
                    "public_name": "name",
                    "cohort": "cohort",
                    "storage_conditions": "conditions",
                    "taxon_id": 9606,
                    "volume": 5000,
                    "date_of_sample_collection": "2013-04-25T11:27:00+01:00",
                    "is_sample_a_control": true,
                    "is_re_submitted_sample": false
                },
                {
                    "actions": {
                        "read": "http://example.org/11111111-2222-3333-4444-666666666666",
                        "create": "http://example.org/11111111-2222-3333-4444-666666666666",
                        "update": "http://example.org/11111111-2222-3333-4444-666666666666",
                        "delete": "http://example.org/11111111-2222-3333-4444-666666666666"
                    },
                    "uuid": "11111111-2222-3333-4444-666666666666",
                    "sanger_sample_id": "S2-test2-ID",
                    "gender": "Male",
                    "sample_type": "RNA",
                    "hmdmc_number": "number",
                    "supplier_sample_name": "name",
                    "common_name": "human",
                    "scientific_name": "Homo sapiens",
                    "ebi_accession_number": "number",
                    "sample_source": "source",
                    "mother": "mother",
                    "father": "father",
                    "sibling": "sibling",
                    "gc_content": "content",
                    "public_name": "name",
                    "cohort": "cohort",
                    "storage_conditions": "conditions",
                    "taxon_id": 9606,
                    "volume": 4000,
                    "date_of_sample_collection": "2013-04-25T11:27:00+01:00",
                    "is_sample_a_control": true,
                    "is_re_submitted_sample": false
                }
            ]
        },
        "by": null,
        "updates": {
            "11111111-2222-3333-4444-555555555555": {
                "volume": 5000
            },
            "11111111-2222-3333-4444-666666666666": {
                "volume": 4000
            }
        }
    }
}
    EOD

  end
end

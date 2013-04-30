require "integrations/requests/apiary/11_sample_resource/spec_helper"
describe "bulk_update_samples", :sample => true do
  include_context "use core context service"
  it "bulk_update_samples" do
    sample = Lims::ManagementApp::Sample.new({
        "gender" => "Male",
        "sample_type" => "RNA",
        "taxon_id" => 1,
        "date_of_sample_collection" => "2013-04-25 10:27 UTC",
        "is_sample_a_control" => true,
        "is_re_submitted_sample" => false,
        "hmdmc_number" => "number",
        "supplier_sample_name" => "name",
        "common_name" => "name",
        "ebi_accession_number" => "number",
        "sample_source" => "source",
        "mother" => "mother",
        "father" => "father",
        "sibling" => "sibling",
        "gc_content" => "content",
        "public_name" => "name",
        "cohort" => "cohort",
        "storage_conditions" => "conditions",
        "dna" => {
          "pre_amplified" => true,
          "date_of_sample_extraction" => "2013-04-25 11:05 UTC",
          "extraction_method" => "method",
          "concentration" => 20,
          "sample_purified" => false,
          "concentration_determined_by_which_method" => "method"
        },
      "cellular_material" => {
        "lysed" => true
      }
    })
    sample.generate_sanger_sample_id
    
    sample2 = Lims::ManagementApp::Sample.new({
        "gender" => "Male",
        "sample_type" => "RNA",
        "taxon_id" => 1,
        "date_of_sample_collection" => "2013-04-25 10:27 UTC",
        "is_sample_a_control" => true,
        "is_re_submitted_sample" => false,
        "hmdmc_number" => "number",
        "supplier_sample_name" => "name",
        "common_name" => "name",
        "ebi_accession_number" => "number",
        "sample_source" => "source",
        "mother" => "mother",
        "father" => "father",
        "sibling" => "sibling",
        "gc_content" => "content",
        "public_name" => "name",
        "cohort" => "cohort",
        "storage_conditions" => "conditions",
        "dna" => {
          "pre_amplified" => true,
          "date_of_sample_extraction" => "2013-04-25 11:05 UTC",
          "extraction_method" => "method",
          "concentration" => 20,
          "sample_purified" => false,
          "concentration_determined_by_which_method" => "method"
        },
      "cellular_material" => {
        "lysed" => true
      }
    })
    sample2.generate_sanger_sample_id
    
    
    save_with_uuid sample => [1,2,3,4,5], sample2 => [1,2,3,4,6]

    header('Accept', 'application/json')
    header('Content-Type', 'application/json')

    response = post "/bulk_update_sample", <<-EOD
    {
    "sample_uuids": [
        "11111111-2222-3333-4444-555555555555",
        "11111111-2222-3333-4444-666666666666"
    ],
    "volume": 5000
}
    EOD
    response.status.should == 200
    response.body.should match_json <<-EOD
    {
    "sample": {
        "actions": {
            "read": "http://example.org/11111111-2222-3333-4444-555555555555",
            "create": "http://example.org/11111111-2222-3333-4444-555555555555",
            "update": "http://example.org/11111111-2222-3333-4444-555555555555",
            "delete": "http://example.org/11111111-2222-3333-4444-555555555555"
        },
        "uuid": "11111111-2222-3333-4444-555555555555",
        "sanger_sample_id": "S2-test-ID",
        "gender": "Male",
        "sample_type": "RNA",
        "hmdmc_number": "number",
        "supplier_sample_name": "new_name",
        "common_name": "name",
        "ebi_accession_number": "number",
        "sample_source": "source",
        "mother": "mother",
        "father": "father",
        "sibling": "sibling",
        "gc_content": "content",
        "public_name": "name",
        "cohort": "cohort",
        "storage_conditions": "conditions",
        "taxon_id": 1,
        "volume": 1000,
        "date_of_sample_collection": "2013-04-25T11:27:00+01:00",
        "is_sample_a_control": true,
        "is_re_submitted_sample": false,
        "dna": {
            "pre_amplified": false,
            "date_of_sample_extraction": "2013-04-25T12:05:00+01:00",
            "extraction_method": "method",
            "concentration": 20,
            "sample_purified": false,
            "concentration_determined_by_which_method": "method"
        },
        "rna": {
            "extraction_method": "method rna",
            "concentration": 50
        },
        "cellular_material": {
            "lysed": false
        }
    }
}
    EOD

  end
end

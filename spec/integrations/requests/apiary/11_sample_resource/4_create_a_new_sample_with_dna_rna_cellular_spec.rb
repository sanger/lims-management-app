require "integrations/requests/apiary/11_sample_resource/spec_helper"
describe "create_a_new_sample_with_dna_rna_cellular", :sample => true do
  include_context "use core context service"
  before do
  Lims::ManagementApp::Sample::SangerSampleID.stub(:generate) do |a|
   "S2-test-ID"
  end
  end
  it "create_a_new_sample_with_dna_rna_cellular" do

    header('Accept', 'application/json')
    header('Content-Type', 'application/json')

    response = post "/samples", <<-EOD
    {
    "sample": {
        "gender": "Male",
        "sample_type": "RNA",
        "scientific_taxon_id": 1,
        "volume": 100,
        "date_of_sample_collection": "2013-04-25 10:27 UTC",
        "is_sample_a_control": true,
        "is_re_submitted_sample": false,
        "hmdmc_number": "number",
        "supplier_sample_name": "name",
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
        "dna": {
            "pre_amplified": true,
            "date_of_sample_extraction": "2013-04-25 11:05 UTC",
            "extraction_method": "method",
            "concentration": 20,
            "sample_purified": false,
            "concentration_determined_by_which_method": "method"
        },
        "rna": {
            "pre_amplified": true,
            "date_of_sample_extraction": "2013-04-25 11:05 UTC",
            "extraction_method": "method",
            "concentration": 20,
            "sample_purified": false,
            "concentration_determined_by_which_method": "method"
        },
        "cellular_material": {
            "lysed": true
        }
    }
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
        "supplier_sample_name": "name",
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
        "scientific_taxon_id": 1,
        "volume": 100,
        "date_of_sample_collection": "2013-04-25T10:27:00+00:00",
        "is_sample_a_control": true,
        "is_re_submitted_sample": false,
        "dna": {
            "pre_amplified": true,
            "date_of_sample_extraction": "2013-04-25T11:05:00+00:00",
            "extraction_method": "method",
            "concentration": 20,
            "sample_purified": false,
            "concentration_determined_by_which_method": "method"
        },
        "rna": {
            "pre_amplified": true,
            "date_of_sample_extraction": "2013-04-25T11:05:00+00:00",
            "extraction_method": "method",
            "concentration": 20,
            "sample_purified": false,
            "concentration_determined_by_which_method": "method"
        },
        "cellular_material": {
            "lysed": true
        }
    }
}
    EOD

  end
end

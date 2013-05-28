require "integrations/requests/apiary/11_sample_resource/spec_helper"
describe "create_a_new_sample_with_unknown_taxon_id_error", :sample => true do
  include_context "use core context service"
  before do
  Lims::ManagementApp::Sample::SangerSampleID.stub(:generate) do |a|
    "S2-test-ID"
  end
  end
  it "create_a_new_sample_with_unknown_taxon_id_error" do

    header('Accept', 'application/json')
    header('Content-Type', 'application/json')

    response = post "/samples", <<-EOD
    {
    "sample": {
        "gender": "Male",
        "sample_type": "RNA",
        "taxon_id": 1234,
        "volume": 100,
        "date_of_sample_collection": "2013-04-25 10:27 UTC",
        "is_sample_a_control": true,
        "is_re_submitted_sample": false,
        "hmdmc_number": "number",
        "supplier_sample_name": "name",
        "common_name": "human",
        "scientific_name": "homo sapiens",
        "ebi_accession_number": "number",
        "sample_source": "source",
        "mother": "mother",
        "father": "father",
        "sibling": "sibling",
        "gc_content": "content",
        "public_name": "name",
        "cohort": "cohort",
        "storage_conditions": "conditions"
    }
}
    EOD
    response.status.should == 400
    response.body.should match_json <<-EOD
    {
    "error": "Taxon ID 1234 unknown"
}
    EOD

  end
end

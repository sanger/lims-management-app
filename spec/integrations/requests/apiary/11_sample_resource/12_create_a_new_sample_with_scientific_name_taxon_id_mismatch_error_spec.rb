require "integrations/requests/apiary/11_sample_resource/spec_helper"
describe "create_a_new_sample_with_scientific_name_taxon_id_mismatch_error", :sample => true do
  include_context "use core context service"
  it "create_a_new_sample_with_scientific_name_taxon_id_mismatch_error" do

    header('Accept', 'application/json')
    header('Content-Type', 'application/json')

    response = post "/samples", <<-EOD
    {
    "sample": {
        "sanger_sample_id_core": "s2",
        "gender": "Male",
        "sample_type": "RNA",
        "taxon_id": 9606,
        "volume": 100,
        "date_of_sample_collection": "2013-04-25 10:27 UTC",
        "is_sample_a_control": true,
        "is_re_submitted_sample": false,
        "hmdmc_number": "number",
        "supplier_sample_name": "name",
        "common_name": "human",
        "scientific_name": "hoomo sapiens",
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
    response.status.should == 422
    response.body.should match_json <<-EOD
    {
    "errors": "Taxon ID 9606 does not match the scientific name 'hoomo sapiens'. Do you mean 'Homo sapiens'?"
}
    EOD

  end
end

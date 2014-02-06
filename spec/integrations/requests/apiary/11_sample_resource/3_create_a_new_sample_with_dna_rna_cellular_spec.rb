require "integrations/requests/apiary/11_sample_resource/spec_helper"
describe "create_a_new_sample_with_dna_rna_cellular", :sample => true do
  include_context "use core context service"
  include_context "timecop"
  it "create_a_new_sample_with_dna_rna_cellular" do

    header('Accept', 'application/json')
    header('Content-Type', 'application/json')

    response = post "/samples", <<-EOD
    {
    "sample": {
        "sanger_sample_id_core": "S2",
        "gender": "Male",
        "state": "published",
        "sample_type": "RNA",
        "disease_phenotype": "normal",
        "age_band": "45-60",
        "taxon_id": 9606,
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
            "lysed": true,
            "donor_id": "donor id"
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
        "state": "published",
        "sanger_sample_id": "S2-1",
        "gender": "Male",
        "sample_type": "RNA",
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
        "storage_conditions": "conditions",
        "disease_phenotype": "normal",
        "age_band": "45-60",
        "taxon_id": 9606,
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
            "lysed": true,
            "donor_id": "donor id"
        }
    }
}
    EOD

  end
end

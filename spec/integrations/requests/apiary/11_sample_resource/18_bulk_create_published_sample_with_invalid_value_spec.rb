require "integrations/requests/apiary/11_sample_resource/spec_helper"
describe "bulk_create_published_sample_with_invalid_value", :sample => true do
  include_context "use core context service"
  include_context "timecop"
  it "bulk_create_published_sample_with_invalid_value" do

    header('Accept', 'application/json')
    header('Content-Type', 'application/json')

    response = post "/actions/bulk_create_sample", <<-EOD
    {
    "bulk_create_sample": {
        "sanger_sample_id_core": "S2",
        "quantity": 3,
        "gender": "Dummy gender",
        "state": "published",
        "sample_type": "Dummy sample type",
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
            "date_of_sample_extraction": "2013-04-25 11:10 UTC",
            "extraction_method": "method",
            "concentration": 20,
            "sample_purified": false,
            "concentration_determined_by_which_method": "method"
        },
        "rna": {
            "pre_amplified": true,
            "date_of_sample_extraction": "2013-04-25 11:10 UTC",
            "extraction_method": "method",
            "concentration": 20,
            "sample_purified": false,
            "concentration_determined_by_which_method": "method"
        },
        "cellular_material": {
            "lysed": true,
            "donor_id": "donor id"
        },
        "genotyping": {
            "country_of_origin": "England",
            "geographical_region": "UK",
            "ethnicity": "english"
        }
    }
}
    EOD
    response.status.should == 422
    response.body.should match_json <<-EOD
    {
    "errors": {
        "ensure_gender_value": [
            "'Dummy gender' is not a valid gender"
        ],
        "ensure_sample_type_value": [
            "'Dummy sample type' is not a valid sample type"
        ],
        "ensure_gender_for_human_sample": [
            "The taxon ID '9606' and the gender 'Dummy gender' do not match."
        ],
        "ensure_published_data": [
            "The sample to be published is not valid. 3 error(s) found: 'Dummy gender' is not a valid gender, 'Dummy sample type' is not a valid sample type, The taxon ID '9606' and the gender 'Dummy gender' do not match."
        ]
    }
}
    EOD

  end
end

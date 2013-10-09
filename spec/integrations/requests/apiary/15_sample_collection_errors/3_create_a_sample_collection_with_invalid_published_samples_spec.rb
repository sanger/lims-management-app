require "integrations/requests/apiary/15_sample_collection_errors/spec_helper"
describe "create_a_sample_collection_with_invalid_published_samples", :sample_collection_errors => true do
  include_context "use core context service"
  it "create_a_sample_collection_with_invalid_published_samples" do

    header('Accept', 'application/json')
    header('Content-Type', 'application/json')

    response = post "/sample_collections", <<-EOD
    {
    "sample_collection": {
        "type": "Study",
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
        ],
        "samples": {
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
}
    EOD
    response.status.should == 422
    response.body.should match_json <<-EOD
    {
    "errors": {
        "ensure_samples": [
            [
                "'Dummy gender' is not a valid gender",
                "'Dummy sample type' is not a valid sample type",
                "The taxon ID '9606' and the gender 'Dummy gender' do not match."
            ]
        ],
        "ensure_published_samples": [
            "The sample to be published is not valid. 3 error(s) found: 'Dummy gender' is not a valid gender, 'Dummy sample type' is not a valid sample type, The taxon ID '9606' and the gender 'Dummy gender' do not match."
        ]
    }
}
    EOD

  end
end

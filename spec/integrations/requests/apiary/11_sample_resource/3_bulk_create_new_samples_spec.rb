require "integrations/requests/apiary/11_sample_resource/spec_helper"
describe "bulk_create_new_samples", :sample => true do
  include_context "use core context service"
  it "bulk_create_new_samples" do

    header('Accept', 'application/json')
    header('Content-Type', 'application/json')

    response = post "/actions/bulk_create_sample", <<-EOD
    {
    "bulk_create_sample": {
        "sanger_sample_id_core": "S2",
        "quantity": 3,
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
            "lysed": true
        },
        "genotyping": {
            "country_of_origin": "England",
            "geographical_region": "UK",
            "ethnicity": "english"
        }
    }
}
    EOD
    response.status.should == 200
    response.body.should match_json <<-EOD
    {
    "bulk_create_sample": {
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
                    "state": "draft",
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
                    "taxon_id": 9606,
                    "volume": 100,
                    "date_of_sample_collection": "2013-04-25T10:27:00+00:00",
                    "is_sample_a_control": true,
                    "is_re_submitted_sample": false,
                    "dna": {
                        "pre_amplified": true,
                        "date_of_sample_extraction": "2013-04-25T11:10:00+00:00",
                        "extraction_method": "method",
                        "concentration": 20,
                        "sample_purified": false,
                        "concentration_determined_by_which_method": "method"
                    },
                    "rna": {
                        "pre_amplified": true,
                        "date_of_sample_extraction": "2013-04-25T11:10:00+00:00",
                        "extraction_method": "method",
                        "concentration": 20,
                        "sample_purified": false,
                        "concentration_determined_by_which_method": "method"
                    },
                    "cellular_material": {
                        "lysed": true
                    },
                    "genotyping": {
                        "country_of_origin": "England",
                        "geographical_region": "UK",
                        "ethnicity": "english"
                    }
                },
                {
                    "actions": {
                        "read": "http://example.org/11111111-2222-3333-4444-666666666666",
                        "create": "http://example.org/11111111-2222-3333-4444-666666666666",
                        "update": "http://example.org/11111111-2222-3333-4444-666666666666",
                        "delete": "http://example.org/11111111-2222-3333-4444-666666666666"
                    },
                    "uuid": "11111111-2222-3333-4444-666666666666",
                    "state": "draft",
                    "sanger_sample_id": "S2-2",
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
                    "taxon_id": 9606,
                    "volume": 100,
                    "date_of_sample_collection": "2013-04-25T10:27:00+00:00",
                    "is_sample_a_control": true,
                    "is_re_submitted_sample": false,
                    "dna": {
                        "pre_amplified": true,
                        "date_of_sample_extraction": "2013-04-25T11:10:00+00:00",
                        "extraction_method": "method",
                        "concentration": 20,
                        "sample_purified": false,
                        "concentration_determined_by_which_method": "method"
                    },
                    "rna": {
                        "pre_amplified": true,
                        "date_of_sample_extraction": "2013-04-25T11:10:00+00:00",
                        "extraction_method": "method",
                        "concentration": 20,
                        "sample_purified": false,
                        "concentration_determined_by_which_method": "method"
                    },
                    "cellular_material": {
                        "lysed": true
                    },
                    "genotyping": {
                        "country_of_origin": "England",
                        "geographical_region": "UK",
                        "ethnicity": "english"
                    }
                },
                {
                    "actions": {
                        "read": "http://example.org/11111111-2222-3333-4444-777777777777",
                        "create": "http://example.org/11111111-2222-3333-4444-777777777777",
                        "update": "http://example.org/11111111-2222-3333-4444-777777777777",
                        "delete": "http://example.org/11111111-2222-3333-4444-777777777777"
                    },
                    "uuid": "11111111-2222-3333-4444-777777777777",
                    "state": "draft",
                    "sanger_sample_id": "S2-3",
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
                    "taxon_id": 9606,
                    "volume": 100,
                    "date_of_sample_collection": "2013-04-25T10:27:00+00:00",
                    "is_sample_a_control": true,
                    "is_re_submitted_sample": false,
                    "dna": {
                        "pre_amplified": true,
                        "date_of_sample_extraction": "2013-04-25T11:10:00+00:00",
                        "extraction_method": "method",
                        "concentration": 20,
                        "sample_purified": false,
                        "concentration_determined_by_which_method": "method"
                    },
                    "rna": {
                        "pre_amplified": true,
                        "date_of_sample_extraction": "2013-04-25T11:10:00+00:00",
                        "extraction_method": "method",
                        "concentration": 20,
                        "sample_purified": false,
                        "concentration_determined_by_which_method": "method"
                    },
                    "cellular_material": {
                        "lysed": true
                    },
                    "genotyping": {
                        "country_of_origin": "England",
                        "geographical_region": "UK",
                        "ethnicity": "english"
                    }
                }
            ]
        },
        "sanger_sample_id_core": "S2",
        "quantity": 3,
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
        "gender": "Male",
        "state": "draft",
        "sample_type": "RNA",
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
            "lysed": true
        },
        "genotyping": {
            "country_of_origin": "England",
            "geographical_region": "UK",
            "ethnicity": "english"
        }
    }
}
    EOD

  end
end

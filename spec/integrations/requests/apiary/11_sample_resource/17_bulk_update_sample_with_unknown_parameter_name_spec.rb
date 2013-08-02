require "integrations/requests/apiary/11_sample_resource/spec_helper"
describe "bulk_update_sample_with_unknown_parameter_name", :sample => true do
  include_context "use core context service"
  it "bulk_update_sample_with_unknown_parameter_name" do
    sample = Lims::ManagementApp::Sample.new({
        "sanger_sample_id" => "S2-1",
        "state" => "draft",
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
        "sanger_sample_id" => "S2-2",
        "state" => "draft",
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
        "by": "dummy",
        "updates": {
            "11111111-2222-3333-4444-555555555555": {
                "dummy parameter": "bla bla"
            },
            "11111111-2222-3333-4444-666666666666": {
                "gender": "dummy"
            }
        }
    }
}
    EOD
    response.status.should == 422
    response.body.should match_json <<-EOD
    {
    "errors": {
        "ensure_by_value": [
            "By parameter's value 'dummy' is not valid"
        ],
        "ensure_updates_parameter": [
            {
                "11111111-2222-3333-4444-555555555555": [
                    "Invalid parameter 'dummy parameter'"
                ],
                "11111111-2222-3333-4444-666666666666": [
                    "'dummy' is not a valid gender"
                ]
            }
        ]
    }
}
    EOD

  end
end

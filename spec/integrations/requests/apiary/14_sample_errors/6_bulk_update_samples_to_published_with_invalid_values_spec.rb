require "integrations/requests/apiary/14_sample_errors/spec_helper"
describe "bulk_update_samples_to_published_with_invalid_values", :sample_errors => true do
  include_context "use core context service"
  include_context "timecop"
  it "bulk_update_samples_to_published_with_invalid_values" do
    sample = Lims::ManagementApp::Sample.new({
        "sanger_sample_id" => "S2-1",
        "gender" => "Male",
        "state" => "draft",
        "sample_type" => "RNA",
        "taxon_id" => 9606,
        "date_of_sample_collection" => "2013-04-25T10:27:00+00:00",
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
        "gender" => "Male",
        "state" => "draft",
        "sample_type" => "RNA",
        "taxon_id" => 9606,
        "date_of_sample_collection" => "2013-04-25T10:27:00+00:00",
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
                "state": "published",
                "gender": "not applicable",
                "volume": 5000
            },
            "11111111-2222-3333-4444-666666666666": {
                "state": "published",
                "volume": 4000
            }
        }
    }
}
    EOD
    response.status.should == 422
    response.body.should match_json <<-EOD
    {
    "errors": {
        "ensure_published_data": "The sample to be published is not valid. 1 error(s) found: The taxon ID '9606' and the gender 'not applicable' do not match."
    }
}
    EOD

  end
end

require 'rest_client'
require 'facets'
require 'optparse'
require 'lims-management-app'
require 'json'

# The following script is used to generate messages 
# on the bus for dev/test purpose for the lims-bridge-app.

options = {}
OptionParser.new do |opt|
  opt.on('-q', '--quantity QUANTITY') { |qty| options[:quantity] = qty.to_i }
  opt.on('-c', '--create') { |o| options[:create] = true }
  opt.on('-w', '--workflow') { |o| options[:workflow] = true }
  opt.on('-u', '--update') do |o| 
    options[:create] = true
    options[:update] = true
  end
  opt.on('-d', '--delete') do |o| 
    options[:create] = true
    options[:delete] = true
  end
end.parse!
options[:create] = true

# helper
def update_parameters(parameters)
  parameters.mash do |k,v|
    case v
    when DateTime then [k, DateTime.now.to_s]
    when TrueClass then [k, false]
    when FalseClass then [k, true]
    when Fixnum then k.to_s == "taxon_id" ? [k, 9604] : [k, v+1]
    when Hash then [k, update_parameters(v)]
    else
      case k
      when :gender then [k, "Hermaphrodite"]
      when :sample_type then [k, "Blood"]
      when :common_name then [k, "great apes"]
      when :scientific_name then [k, "Hominidae"]
      when :state then [k,v]
      else [k, "new #{v}"]
      end
    end
  end
end

# Workflow example
# 1 - bulk create 2 empty samples - draft
# 2 - bulk update 2 samples - draft
# 3 - finalize bulk update 2 samples - published
if options[:workflow]
  parameters = {:bulk_create_sample => {:user => "username", :sanger_sample_id_core => "S2",  :quantity => 1}}
  response = RestClient.post("http://localhost:9292/actions/bulk_create_sample",
                             parameters.to_json,
                             {'Content-Type' => 'application/json', 'Accept' => 'application/json'})
  result = JSON.parse(response)
  sample_uuids = [].tap do |uuids|
    result["bulk_create_sample"]["result"]["samples"].each do |sample|
      uuids << sample["uuid"]
    end
  end
  puts response
  sanger_sample_ids = [].tap do |ids|
    result["bulk_create_sample"]["result"]["samples"].each do |sample|
      ids << sample["sanger_sample_id"]
    end
  end

  parameters = {"bulk_update_sample"=>{"user"=>"username","by"=>"sanger_sample_id","updates"=>{sanger_sample_ids.first=>{"gender"=>"Male","sample_type"=>"Tissue Non-Tumour","supplier_sample_name"=>"TEST_SAMPLE_1","volume"=>1,"is_sample_a_control"=>false,"is_re_submitted_sample"=>false,"cellular_material"=>{"lysed"=>false}}}}}
  puts parameters.to_json
  response = RestClient.post("http://localhost:9292/actions/bulk_update_sample",
                             parameters.to_json,
                             {'Content-Type' => 'application/json', 'Accept' => 'application/json'})
  puts
  puts response

  updated_parameters = {}.tap do |h|
    sample_uuids.each do |uuid|
      h[uuid] = {:gender => "Male", :sample_type => "RNA", :taxon_id => 9606, :common_name => "man", :scientific_name => "homo sapiens"}
    end
  end
  response = RestClient.post("http://localhost:9292/actions/bulk_update_sample",
                             {:bulk_update_sample => {:updates => updated_parameters}}.to_json,
                             {'Content-Type' => 'application/json', 'Accept' => 'application/json'})
  puts
  puts response

  updated_parameters = {}.tap do |h|
    sample_uuids.each do |uuid|
      h[uuid] = {:state => "published"}
    end
  end
  response = RestClient.post("http://localhost:9292/actions/bulk_update_sample",
                             {:bulk_update_sample => {:updates => updated_parameters}}.to_json,
                             {'Content-Type' => 'application/json', 'Accept' => 'application/json'})
  puts
  puts response

elsif options[:quantity] == 0 || options[:quantity].nil?

  # Create a sample
  parameters = {
    :sample => {
      :sanger_sample_id_core => "StudyX",
      :gender => "Male",
      :sample_type => "Cell Pellet",
      :taxon_id => 9606,
      :volume => 100,
      :supplier_sample_name => "supplier sample name",
      :common_name => "man",
      :scientific_name => "homo sapiens",
      :hmdmc_number => "123456",
      :ebi_accession_number => "accession number",
      :sample_source => "sample source",
      :mother => "mother",
      :father => "father",
      :sibling => "sibling",
      :gc_content => "gc content",
      :public_name => "public name",
      :cohort => "cohort",
      :storage_conditions => "storage conditions",
      :date_of_sample_collection => "2013-06-24",
      :is_sample_a_control => true,
      :is_re_submitted_sample => false,
      :dna => {
        :pre_amplified => false,
        :date_of_sample_extraction => "2013-06-02",
        :extraction_method => "extraction method",
        :concentration => 120,
        :sample_purified => false,
        :concentration_determined_by_which_method => "method"
      },
      :rna => {
        :pre_amplified => true,
        :date_of_sample_extraction => "2013-06-02",
        :extraction_method => "extraction method",
        :concentration => 120,
        :sample_purified => true,
        :concentration_determined_by_which_method => "method"
      },
      :cellular_material => {
        :lysed => true
      },
      :genotyping => {
        :country_of_origin => "england",
        :geographical_region => "europe",
        :ethnicity => "english"
      }
    }
  }

  if options[:create]
    response = RestClient.post("http://localhost:9292/samples",
                               parameters.to_json,
                               {'Content-Type' => 'application/json', 'Accept' => 'application/json'})
    result = JSON.parse(response)
    puts response
    puts
    sample_uuid = result["sample"]["uuid"]
  end

  # Update a sample
  if options[:update]
    updated_parameters = update_parameters(parameters) 
    response = RestClient.put("http://localhost:9292/#{sample_uuid}",
                              (updated_parameters[:sample] - [:sanger_sample_id_core]).to_json,
                              {'Content-Type' => 'application/json', 'Accept' => 'application/json'})
    puts response
    puts
  end

  # Delete a sample
  if options[:delete]
    response = RestClient.delete("http://localhost:9292/#{sample_uuid}",
                                 {'Content-Type' => 'application/json', 'Accept' => 'application/json'})
    puts response
    puts
  end

else

  # Sample bulk create
  sample_uuids = []
  parameters = {
    :bulk_create_sample => {
      :quantity => options[:quantity],
      :sanger_sample_id_core => "StudyX",
      :gender => "Male",
      :sample_type => "RNA",
      :taxon_id => 9606,
      :volume => 100,
      :supplier_sample_name => "supplier sample name",
      :common_name => "man",
      :scientific_name => "homo sapiens",
      :hmdmc_number => "123456",
      :ebi_accession_number => "accession number",
      :sample_source => "sample source",
      :mother => "mother",
      :father => "father",
      :sibling => "sibling",
      :gc_content => "gc content",
      :public_name => "public name",
      :cohort => "cohort",
      :storage_conditions => "storage conditions",
      :date_of_sample_collection => "2013-06-24",
      :is_sample_a_control => false,
      :is_re_submitted_sample => true,
      :dna => {
        :pre_amplified => false,
        :date_of_sample_extraction => "2013-06-02",
        :extraction_method => "extraction method",
        :concentration => 120,
        :sample_purified => false,
        :concentration_determined_by_which_method => "method"
      },
      :cellular_material => {
        :lysed => false
      },
      :genotyping => {
        :country_of_origin => "england",
        :geographical_region => "europe",
        :ethnicity => "english"
      }
    }
  }

  if options[:create]
    response = RestClient.post("http://localhost:9292/actions/bulk_create_sample",
                               parameters.to_json,
                               {'Content-Type' => 'application/json', 'Accept' => 'application/json'})
    result = JSON.parse(response)
    sample_uuids = [].tap do |uuids|
      result["bulk_create_sample"]["result"]["samples"].each do |sample|
        uuids << sample["uuid"]
      end
    end
    puts response
    puts
  end

  # Sample bulk update
  if options[:update]
    updated_parameters = {}.tap do |h|
      sample_uuids.each do |uuid|
        h[uuid] = update_parameters(parameters[:bulk_create_sample].merge({:state => "published"}) - [:quantity, :sanger_sample_id_core])
      end
    end

    response = RestClient.post("http://localhost:9292/actions/bulk_update_sample",
                               {:bulk_update_sample => {:updates => updated_parameters}}.to_json,
                              {'Content-Type' => 'application/json', 'Accept' => 'application/json'})
    puts response
    puts
  end

  # Bulk Delete samples
  if options[:delete]
    parameters = {:bulk_delete_sample => {:sample_uuids => sample_uuids}} 
    response = RestClient.post("http://localhost:9292/actions/bulk_delete_sample",
                               parameters.to_json,
                                 {'Content-Type' => 'application/json', 'Accept' => 'application/json'})
    puts response
    puts
  end
end

require 'rest_client'
require 'facets'
require 'optparse'
require 'lims-management-app'
require 'json'

options = {}
OptionParser.new do |opt|
  opt.on('-q', '--quantity QUANTITY') do |qty|
    options[:quantity] = qty
  end
end.parse!

# helper
def update_parameters(parameters)
  parameters.mash do |k,v|
    case v
    when DateTime then [k, DateTime.now.to_s]
    when TrueClass then [k, false]
    when FalseClass then [k, true]
    when Fixnum then [k, v+1]
    when Hash then [k, update_parameters(v)]
    else
      case k
      when :gender then [k, "Hermaphrodite"]
      when :sample_type then [k, "Blood"]
      else [k, "new #{v}"]
      end
    end
  end
end

if options[:quantity] == 1 || options[:quantity].nil?

  # Create a sample
  parameters = {
    :sample => {
      :gender => "Male",
      :sample_type => "RNA",
      :taxon_id => 45,
      :volume => 100,
      :supplier_sample_name => "supplier sample name",
      :common_name => "common name",
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
      }
    }
  }

  response = RestClient.post("http://localhost:9292/samples",
                             parameters.to_json,
                             {'Content-Type' => 'application/json', 'Accept' => 'application/json'})
  result = JSON.parse(response)
  sample_uuid = result["sample"]["uuid"]
  puts response
  puts

  # Update a sample
  updated_parameters = update_parameters(parameters) 
  response = RestClient.put("http://localhost:9292/#{sample_uuid}",
                            updated_parameters[:sample].to_json,
                            {'Content-Type' => 'application/json', 'Accept' => 'application/json'})
  puts response
  puts

  # Delete a sample
  response = RestClient.delete("http://localhost:9292/#{sample_uuid}",
                               {'Content-Type' => 'application/json', 'Accept' => 'application/json'})
  puts response
  puts

else

  # Sample bulk create
  parameters = {
    :bulk_create_sample => {
      :quantity => options[:quantity],
      :gender => "Male",
      :sample_type => "RNA",
      :taxon_id => 45,
      :volume => 100,
      :supplier_sample_name => "supplier sample name",
      :common_name => "bulk common name",
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
      }
    }
  }

  response = RestClient.post("http://localhost:9292/actions/bulk_create_sample",
                             parameters.to_json,
                             {'Content-Type' => 'application/json', 'Accept' => 'application/json'})
  puts response
end

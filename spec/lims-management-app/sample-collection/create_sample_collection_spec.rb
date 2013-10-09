require 'lims-management-app/spec_helper'
require 'lims-core/persistence/store'
require 'lims-management-app/sample-collection/sample_collection_shared'
require 'lims-management-app/sample-collection/create_sample_collection'

module Lims::ManagementApp
  describe SampleCollection::CreateSampleCollection do
    include_context "collection factory"
    include_context "for application", "collection creation"
    include_context "sample collection configuration"

    let!(:store) { Lims::Core::Persistence::Store.new }
    let(:parameters) {
      {
        :store => store,
        :application => application,
        :user => user
      }
    }

    context "when the action is not valid" do
      shared_examples_for "an invalid sample" do |error_message|
        it "fails" do
          action = described_class.new(action_parameters)
          action.valid?.should == false
          action.errors.first.first.message.should == error_message if error_message
        end
      end

      context "without a type" do
        let(:action_parameters) { parameters }
        it_behaves_like "an invalid sample", "Type must not be blank" 
      end

      context "with an invalid type" do
        let(:action_parameters) { parameters.merge(:type => "dummy") }
        it_behaves_like "an invalid sample", "'dummy' is not a valid collection type" 
      end

      context "with invalid data types" do
        let(:action_parameters) { parameters.merge(sample_collection_action_parameters(:data => [
          {"key" => "key_string", "type" => "dummy", "value" => "value"}
        ])) }
        it_behaves_like "an invalid sample", "'dummy' is not a valid type. Supported types are string, bool, int, url, uuid" 
      end

      context "without data triple key/type/value" do
        let(:action_parameters) { parameters.merge(sample_collection_action_parameters(:data => [1])) }
        it_behaves_like "an invalid sample", "Data must be a hash containing the element 'key' and 'value'" 
      end

      context "with 2 data with the same key" do
        let(:action_parameters) do
          parameters.merge(sample_collection_action_parameters(:data => sample_collection_action_data.tap { |h|
            h << {"key" => "key_bool", "type" => "int", "value" => 123}
          }))
        end
        it_behaves_like "an invalid sample", "Duplicate keys have been found" 
      end


      context "when creating samples" do
        let(:parameters_with_samples) { parameters.merge("type" => "Study").merge(:samples => full_sample_parameters).tap do |p|
          p[:samples]["quantity"] = 3
          p[:samples]["sanger_sample_id_core"] = "test"
        end
        }

        context "without a quantity" do
          let(:action_parameters) { parameters_with_samples.tap do |p| 
            p[:samples].delete("quantity") 
          end
          }
          it_behaves_like "an invalid sample", "The quantity of samples is required"
        end

        context "with a negative quantity" do
          let(:action_parameters) { parameters_with_samples.tap do |p| 
            p[:samples]["quantity"] = -1 
          end
          }
          it_behaves_like "an invalid sample", "The quantity '-1' is not valid"
        end

        context "without a sanger sample id core" do
          let(:action_parameters) { parameters_with_samples.tap { |p| p[:samples].delete("sanger_sample_id_core") }}
          it_behaves_like "an invalid sample", "A Sanger sample id core is needed"
        end

        context "with an invalid parameter" do
          let(:action_parameters) { parameters_with_samples.tap do |p| 
            p[:samples]["dummy"] = "dummy"
          end
          }
          it_behaves_like "an invalid sample", ["Invalid parameter 'dummy'"]
        end

        context "with an invalid gender" do
          let(:action_parameters) { parameters_with_samples.tap do |p| 
            p[:samples]["gender"] = "dummy"
          end
          }
          it_behaves_like "an invalid sample", ["'dummy' is not a valid gender"]
        end

        context "with an invalid sample type" do
          let(:action_parameters) { parameters_with_samples.tap do |p| 
            p[:samples]["sample_type"] = "dummy"
          end
          }
          it_behaves_like "an invalid sample", ["'dummy' is not a valid sample type"]
        end

        context "with an invalid state" do
          let(:action_parameters) { parameters_with_samples.tap do |p| 
            p[:samples]["state"] = "dummy"
          end
          }
          it_behaves_like "an invalid sample", ["'dummy' is not a valid state"]
        end

        context "with an invalid combination taxon_id/gender for humans" do
          let(:action_parameters) { parameters_with_samples.tap do |p| 
            p[:samples][:taxon_id] = 9606
            p[:samples][:gender] = "Not applicable"
          end
          }
          it_behaves_like "an invalid sample", ["The taxon ID '9606' and the gender 'Not applicable' do not match."]
        end

        context "with a published state" do
          context "without a gender" do
            let(:action_parameters) { parameters_with_samples.tap do |p| 
              p[:samples][:state] = "published"
              p[:samples].delete(:gender) 
            end
            }
            it_behaves_like "an invalid sample", "The sample to be published is not valid. 1 error(s) found: Gender must be set" 
          end

          context "without a sample_type" do
            let(:action_parameters) { parameters_with_samples.tap do |p| 
              p[:samples][:state] = "published"
              p[:samples].delete(:sample_type) 
            end
            }
            it_behaves_like "an invalid sample", "The sample to be published is not valid. 1 error(s) found: Sample_type must be set" 
          end

          context "without a taxon_id" do
            let(:action_parameters) { parameters_with_samples.tap do |p| 
              p[:samples][:state] = "published"
              p[:samples].delete(:taxon_id) 
            end
            }
            it_behaves_like "an invalid sample", "The sample to be published is not valid. 1 error(s) found: Taxon_id must be set" 
          end
        end
      end
    end


    shared_examples_for "a new sample collection" do
      it "has valid parameters" do
        described_class.new(parameters.merge({
          :type => type, 
          :data => sample_collection_action_data, 
          :sample_uuids => []
        })).valid?.should == true
      end

      it "creates a sample collection" do
        Lims::Core::Persistence::Session.any_instance.should_receive(:save)
        result = subject.call
        collection = result[:sample_collection]
        collection.should be_a(SampleCollection)

        collection.data[0].should be_a(SampleCollection::SampleCollectionData::String)
        collection.data[0].key.should == "key_string"
        collection.data[0].value.should == "value"
        collection.data[1].should be_a(SampleCollection::SampleCollectionData::Int)
        collection.data[1].key.should == "key_int"
        collection.data[1].value.should == 1 
        collection.data[2].should be_a(SampleCollection::SampleCollectionData::Url)
        collection.data[2].key.should == "key_url"
        collection.data[2].value.should == "http://www.sanger.ac.uk"
        collection.data[3].should be_a(SampleCollection::SampleCollectionData::Bool)
        collection.data[3].key.should == "key_bool"
        collection.data[3].value.should == true 
        collection.data[4].should be_a(SampleCollection::SampleCollectionData::Bool)
        collection.data[4].key.should == "key_bool2"
        collection.data[4].value.should == false 
        collection.data[5].should be_a(SampleCollection::SampleCollectionData::Uuid)
        collection.data[5].key.should == "key_uuid"
        collection.data[5].value.should == "11111111-2222-3333-4444-555555555555"
      end
    end


    context "when the action is valid" do
      include_context "create object"
      it_behaves_like "an action"
      let(:type) { "Study" }

      subject {
        described_class.new(parameters) do |a,s|
          a.type = "Study"
          a.data = data
          # we do not test sample_uuids here as it needs persistence
          # @see the corresponding spec in persistence
          a.sample_uuids = []
        end
      }

      context "with data explicitely typed" do
        let(:data) { sample_collection_action_data }
        it_behaves_like "a new sample collection"
      end

      context "with data non typed" do
        let(:data) { sample_collection_action_data_no_type }
        it_behaves_like "a new sample collection"
      end

      context "with new samples" do
        let(:data) { sample_collection_action_data_no_type }
        subject {
          described_class.new(parameters) do |a,s|
            a.type = "Study"
            a.data = data
            a.samples = samples
          end
        }

        before do
          Lims::ManagementApp::Sample::SangerSampleIdNumber::SangerSampleIdNumberPersistor.any_instance.stub(:generate_new_number) { 1 }
        end

        shared_examples_for "creating samples through create collection action" do |state|
          it "has valid parameters" do
            described_class.new(parameters.merge({
              :type => type, 
              :data => sample_collection_action_data, 
              :samples => samples
            })).valid?.should == true
          end

          it "creates 3 samples" do
            Lims::Core::Persistence::Session.any_instance.should_receive(:save)
            result = subject.call
            collection = result[:sample_collection]
            collection.should be_a(SampleCollection)

            collection.samples.should be_a(Array)
            collection.samples.size.should == 3
            collection.samples.each do |sample|
              sample.should be_a(Sample)
              full_sample_parameters.each do |k,v|
                if [:dna, :rna, :cellular_material, :genotyping].include?(k)
                  v.each do |k2,v2|
                    sample.send(k).send(k2).to_s.should == v2.to_s
                  end
                else
                  sample.send(k).to_s.should == v.to_s
                end
              end
              sample.state.should == state
            end
          end
        end

        context "with a draft state" do
          let(:samples) { full_sample_parameters.merge("quantity" => 3, "sanger_sample_id_core" => "test") } 
          it_behaves_like "creating samples through create collection action", "draft"
        end

        context "with a published state" do
          let(:samples) { full_sample_parameters.merge("state" => "published", "quantity" => 3, "sanger_sample_id_core" => "test") } 
          it_behaves_like "creating samples through create collection action", "published"
        end
      end
    end
  end
end

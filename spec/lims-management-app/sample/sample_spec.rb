require 'lims-management-app/sample/sample_shared'

module Lims::ManagementApp
  describe Sample do

    # Macros
    def self.it_has_a(attribute, type = nil)
      it "responds to #{attribute}" do
        subject.should respond_to(attribute)
      end

      it "can assign #{attribute}" do
        value = mock(:attribute)
        subject.send("#{attribute}=", value)
        subject.send(attribute).should == value
      end
    end

    def self.it_needs_a(attribute)
      context "is invalid" do
        subject { Sample.new(common_sample_parameters - [attribute]) }
        it { subject.valid?.should == false }
        context "after validation" do
          before { subject.validate }
          it "#{attribute} is required" do
            subject.errors[attribute].should_not be_empty
          end
        end
      end
    end
    # End Macros

    include_context "sample factory"
    context "valid" do
      subject { 
        sample = new_full_sample 
        sample
      }

      it "is a valid sample" do
        subject.valid?.should == true
      end

      %w(hmdmc_number ebi_accession_number sample_source
    mother father sibling gc_content public_name cohort storage_conditions).each do |name|
        it_has_a name
      end

      it_has_a :supplier_sample_name
      it_needs_a :supplier_sample_name
      it_has_a :common_name
      it_needs_a :common_name
      it_has_a :taxon_id
      it_needs_a :taxon_id
      it_has_a :gender
      it_needs_a :gender
      it_has_a :sanger_sample_id
      it_has_a :sample_type
      it_needs_a :sample_type
      it_has_a :volume
      it_has_a :date_of_sample_collection
      it_has_a :is_sample_a_control
      it_has_a :is_re_submitted_sample
      it_has_a :dna
      it_has_a :rna
      it_has_a :cellular_material
      it_has_a :genotyping
    end


    context "invalid" do
      it "is invalid if the gender is not known" do
        Sample.new(full_sample_parameters.merge({:gender => "dummy"})).valid?.should == false
      end

      it "is invalid if the sample_type is not known" do
        Sample.new(full_sample_parameters.merge({:sample_type => "dummy"})).valid?.should == false
      end

      it "is invalid if a human sample has an unknown gender" do
        Sample.new(full_sample_parameters.merge({:taxon_id => 9606, :gender => "Unknown"})).valid?.should == false
      end

      it "is invalid if a human sample has a not applicable gender" do
        Sample.new(full_sample_parameters.merge({:taxon_id => 9606, :gender => "Not applicable"})).valid?.should == false
      end
    end
  end
end

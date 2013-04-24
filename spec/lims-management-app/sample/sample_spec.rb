require 'lims-management-app/sample/sample'
require 'lims-management-app/sample/dna/dna'

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
        subject { Sample.new(parameters - [attribute]) }
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

    let(:parameters) { {:hmdmc_number => "test", :supplier_sample_name => "test", :common_name => "test",
    :ebi_accession_number => "test", :sample_source => "test", :mother => "test", :father => "test",
    :sibling => "test", :gc_content => "test", :public_name => "test", :cohort => "test", 
    :storage_conditions => "test", :taxon_id => 1, :gender => "male", :sanger_sample_id => "test",
    :sample_type => "RNA", :volume => 1, :date_of_sample_collection => Time.now, 
    :is_sample_a_control => true, :is_re_submitted_sample => false} }

    context "valid" do
      subject { Sample.new(parameters) }

      it "is a valid sample" do
        subject.valid?.should == true
      end

      %w(hmdmc_number supplier_sample_name common_name ebi_accession_number sample_source
    mother father sibling gc_content public_name cohort storage_conditions).each do |name|
        it_has_a name
      end

      it_has_a :taxon_id
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
    end


    context "invalid" do
      it "is invalid if the gender is not known" do
        Sample.new(parameters.merge({:gender => "dummy"})).valid?.should == false
      end

      it "is invalid if the sample_type is not known" do
        Sample.new(parameters.merge({:sample_type => "dummy"})).valid?.should == false
      end
    end
  end
end

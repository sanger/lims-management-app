require 'spec_helper'
require 'lims-core/persistence'
require 'spec_helper'

shared_examples "an action" do
  context "to be valid" do
    its(:user) { should_not be_nil }
    its(:application) { should_not be_nil }
    its(:application) { should_not be_empty }
    its(:store) { should_not be_nil }
    it { should respond_to(:call) }
    it { should respond_to(:revert) }
  end
end

shared_context "for application" do |application_string|
  let(:user) { mock(:user) }
  let(:application) { application_string }
end

shared_context "create object" do
  let(:uuid) { "11111111-2222-3333-4444-555555555555" }
  before do
    Lims::Core::Persistence::Session.any_instance.tap do |session|
      session.stub(:save_all)
      session.stub(:uuid_for!) { uuid }
    end
  end
end

module Helper
  def save(object)
    store.with_session do |session|
      session << object
      lambda { session.id_for(object) }
    end.call 
  end
end

RSpec.configure do |c|
  c.include Helper
end

shared_examples_for "changing the table" do |table, quantity|
  it "modify the #{table} table" do
    expect do
      subject.call
    end.to change { db[table.to_sym].count }.by(quantity)
  end
end

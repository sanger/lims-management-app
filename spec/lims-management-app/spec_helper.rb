require 'lims-core/persistence/store'
require 'lims-core/persistence/session'

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
      session.stub(:save)
      session.stub(:uuid_for!) { uuid }
    end
  end
end

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

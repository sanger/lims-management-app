require 'common'

::Sequel.migration do
  up do
    self[:searches].each do |search|
      search[:filter_parameters].andtap do |value|
        search[:filter_parameters] = Lims::Core::Helpers::to_json(Marshal.load(value))
      end
      self[:searches].where(:id => search.delete(:id)).update(search)
    end
  end

  down do
    self[:searches].each do |search|
      search[:filter_parameters].andtap do |value|
        search[:filter_parameters] = Marshal.dump(Lims::Core::Helpers::load_json(value))
      end
      self[:searches].where(:id => search.delete(:id)).update(search)
    end
  end
end

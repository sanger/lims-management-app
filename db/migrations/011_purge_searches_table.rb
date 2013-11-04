# From lims-core v3.1.0.1.0, the searches filter_parameters
# doesn't have the same format in the database.
::Sequel.migration do
  up do
    self[:searches].delete
  end
end

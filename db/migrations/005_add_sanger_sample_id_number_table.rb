Sequel.migration do
  up do
    create_table :sanger_sample_id_number do
      primary_key :id
      Integer :number
    end

    # Initialize the first number
    self[:sanger_sample_id_number].insert(:number => 0)
  end

  down do
    drop_table :sanger_sample_id_number
  end
end

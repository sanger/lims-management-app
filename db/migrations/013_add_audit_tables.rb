require 'lims-core/persistence/sequel/migrations'
Sequel.migration &Lims::Core::Persistence::Sequel::Migrations::AddAuditTables::migration(
  [:taxonomies, :sanger_sample_id_number]
)

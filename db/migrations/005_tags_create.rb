# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:tags) do
      column :id, :uuid, primary_key: true, default: Sequel.function(:gen_random_uuid)
      String :name, null: false, unique: true

      DateTime :created_at
      DateTime :updated_at
    end
  end
end

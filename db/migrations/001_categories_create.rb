# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:categories) do
      primary_key :id

      String :item_type, unique: true, null: false
      String :description

      DateTime :created_at
      DateTime :updated_at
    end
  end
end

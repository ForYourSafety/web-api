# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:contacts) do
      uuid :id, primary_key: true
      foreign_key :item_id, table: :items, null: false, on_delete: :cascade
      Integer :contact_type, null: false
      String :value_secure, null: false

      DateTime :created_at
      DateTime :updated_at
    end
  end
end

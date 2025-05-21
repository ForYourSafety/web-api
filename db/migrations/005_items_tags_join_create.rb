# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:items_tags) do
      foreign_key :item_id, :items, type: :uuid, on_delete: :cascade

      foreign_key :tag_id, :tags, on_delete: :cascade

      primary_key %i[item_id tag_id]

      DateTime :created_at
    end
  end
end

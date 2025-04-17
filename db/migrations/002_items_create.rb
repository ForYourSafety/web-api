# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:items) do
      primary_key :id
      foreign_key :delegate_id, table: :delegates

      String :category, null: false
      String :itemname, null: false
      String :description
      String :location

      DateTime :created_at
      DateTime :updated_at
    end
  end
end

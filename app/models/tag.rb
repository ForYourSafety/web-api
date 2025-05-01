# frozen_string_literal: true

require 'json'
require 'sequel'

module LostNFound
  # model for item tags
  class Tag < Sequel::Model
    many_to_many :items, class: 'LostNFound::Item', join_table: :items_tags

    plugin :timestamps, update_on_create: true
    plugin :whitelist_security
    set_allowed_columns :name

    def to_json(options = {})
      JSON({ data: { type: 'tag', attributes: { id:, name: } } }, options)
    end
  end
end

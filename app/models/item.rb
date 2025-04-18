# frozen_string_literal: true

require 'json'
require 'sequel'

module LostNFound
  # model for lost items
  class Item < Sequel::Model
    many_to_one :category

    plugin :timestamps, update_on_create: true

    def to_json(options = {}) # rubocop:disable Metrics/MethodLength
      JSON(
        {
          data: {
            type: 'item',
            attributes: {
              id:,
              category:,
              itemname:,
              description:,
              location:
            }
          },
          included: {
            category:
          }
        }, options
      )
    end
  end
end

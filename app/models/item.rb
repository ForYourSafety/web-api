# frozen_string_literal: true

require 'json'
require 'sequel'

module LostNFound
  # model for lost items
  class Item < Sequel::Model
    one_to_many :contacts

    plugin :uuid, field: :id

    plugin :enum
    enum :type, lost: 0, found: 1

    plugin :association_dependencies, contacts: :destroy
    plugin :timestamps, update_on_create: true

    def to_json(options = {}) # rubocop:disable Metrics/MethodLength
      JSON(
        {
          data: {
            type: 'item',
            attributes: {
              id:,
              type:,
              name:,
              description:,
              resolved:
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

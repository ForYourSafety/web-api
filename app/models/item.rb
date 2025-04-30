# frozen_string_literal: true

require 'json'
require 'sequel'

module LostNFound
  # model for lost items
  class Item < Sequel::Model
    one_to_many :contacts
    many_to_one :creator, class: 'LostNFound::Account', key: :created_by

    plugin :uuid, field: :id

    plugin :enum
    enum :type, lost: 0, found: 1

    plugin :association_dependencies, contacts: :destroy
    plugin :timestamps, update_on_create: true

    plugin :whitelist_security
    set_allowed_columns :id, :type, :name, :description, :location, :person_info

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
              location:,
              person_info:,
              created_by:,
              resolved:
            }
          },
          included: {
            contacts:
          }
        }, options
      )
    end
  end
end

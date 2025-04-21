# frozen_string_literal: true

require 'json'
require 'sequel'

module LostNFound
  # models a category
  class Category < Sequel::Model
    one_to_many :items
    plugin :association_dependencies, items: :destroy
    plugin :timestamps

    def to_json(options = {}) # rubocop:disable Metrics/MethodLength
      JSON(
        {
          data: {
            type: 'category',
            attributes: {
              id:,
              item_type:,
              description:
            }
          }
        }, options
      )
    end
  end
end

# frozen_string_literal: true

require 'json'
require 'sequel'

module LostNFound
  # models a delegate
  class Delegate < Sequel::Model
    one_to_many :items
    plugin :association_dependencies, items: :destroy
    plugin :timestamps

    def to_json(options = {}) # rubocop:disable Metrics/MethodLength
      JSON(
        {
          data: {
            type: 'delegate',
            attributes: {
              id:,
              name:,
              email:,
              phone_number:
            }
          }
        }, options
      )
    end
  end
end

# frozen_string_literal: true

require 'json'
require 'sequel'

module LostNFound
  # models a contact
  class Contact < Sequel::Model
    many_to_one :item
    plugin :uuid, field: :id

    plugin :enum
    enum :contact_type, other: 0, email: 1, phone: 2, address: 3, facebook: 4, twitter: 5, instagram: 6, whatsapp: 7,
                        telegram: 8, line: 9, signal: 10, wechat: 11, discord: 12

    plugin :association_dependencies, item: :destroy
    plugin :timestamps

    def to_json(options = {}) # rubocop:disable Metrics/MethodLength
      JSON(
        {
          data: {
            type: 'contact',
            attributes: {
              id:,
              item_id:,
              contact_type:,
              value:
            }
          },
          included: {
            item:
          }
        }, options
      )
    end
  end
end

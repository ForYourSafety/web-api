# frozen_string_literal: true

require 'json'
require 'sequel'

module LostNFound
  # models a contact
  class Contact < Sequel::Model
    many_to_one :item
    plugin :uuid, field: :id

    plugin :enum
    enum :contact_type, :other, :email, :phone, :address, :facebook, :twitter, :instagram, :whatsapp, :telegram, :line,
         :signal, :wechat, :discord

    plugin :association_dependencies, items: :destroy
    plugin :timestamps

    def to_json(options = {}) # rubocop:disable Metrics/MethodLength
      JSON(
        {
          data: {
            type: 'category',
            attributes: {
              id:,
              item_id:,
              contact_type:,
              value:
            }
          }
        }, options
      )
    end
  end
end

# frozen_string_literal: true

require 'roda'
require 'json'

require_relative '../models/item'

module LostNFound
  # Web controller for LostNFound API
  class Api < Roda
    plugin :environments
    plugin :halt

    configure do
      Item.setup
    end

    route do |routing| # rubocop:disable Metrics/BlockLength
      response['Content-Type'] = 'application/json'

      routing.root do
        { message: 'LostNFound API up at /api/v1' }.to_json
      end

      routing.on 'api' do
        routing.on 'v1' do
          routing.on 'item' do
            # GET api/v1/item/[uuid]
            routing.get String do |id|
              Item.find(id).to_json
            rescue StandardError
              routing.halt 404, { message: 'Item not found' }.to_json
            end

            # GET api/v1/item
            routing.get do
              output = { item_ids: Item.all }
              JSON.pretty_generate(output)
            end

            # POST api/v1/item
            routing.post do
              new_data = JSON.parse(routing.body.read)
              new_item = Item.new(new_data)

              if new_item.save
                response.status = 201
                { message: 'Item saved', id: new_item.uuid }.to_json
              else
                routing.halt 400, { message: 'Could not save item' }.to_json
              end
            end
          end
        end
      end
    end
  end
end

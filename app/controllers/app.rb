# frozen_string_literal: true

require 'roda'
require 'json'
require 'logger'

module LostNFound
  # Web controller for LostNFound API
  class Api < Roda
    plugin :halt

    route do |routing|
      response['Content-Type'] = 'application/json'

      routing.root do
        { message: 'LostNFound API up at /api/v1' }.to_json
      end
      @api_root = 'api/v1'
      routing.on @api_root do
        routing.on 'delegates' do
          @dele_route = "#{@api_root}/delegates"

          routing.on String do |dele_id|
            routing.on 'items' do
              @item_route = "#{@api_root}/delegates/#{dele_id}/items"
              # GET api/v1/delegates/[dele_id]/items/[item_id]
              routing.get String do |item_id|
                item = Item.where(delegate_id: dele_id, id: item_id).first
                item ? item.to_json : raise('item not found')
              rescue StandardError => e
                routing.halt 404, { message: e.message }.to_json
              end

              # GET api/v1/delegates/[dele_id]/items
              routing.get do
                output = { data: Delegate.first(id: dele_id).items }
                JSON.pretty_generate(output)
              rescue StandardError
                routing.halt 404, message: 'Could not find documents'
              end

              # POST api/v1/delegates/[ID]/items
              routing.post do
                new_data = JSON.parse(routing.body.read)
                dele = Delegate.first(id: dele_id)
                new_item = dele.add_item(new_data)

                if new_item
                  response.status = 201
                  response['Location'] = "#{@item_route}/#{new_item.id}"
                  { message: 'Item saved', data: new_item }.to_json
                else
                  routing.halt 400, 'Could not save item'
                end
              rescue StandardError
                routing.halt 500, { message: 'Database error' }.to_json
              end
            end

            # GET api/v1/delegates/[ID]
            routing.get do
              dele = Delegate.first(id: dele_id)
              dele ? dele.to_json : raise('Delegate not found')
            rescue StandardError => e
              routing.halt 404, { message: e.message }.to_json
            end
          end

          # GET api/v1/delegates
          routing.get do
            output = { data: Delegate.all }
            JSON.pretty_generate(output)
          rescue StandardError
            routing.halt 404, { message: 'Could not find delegates' }.to_json
          end

          # POST api/v1/delegates
          routing.post do
            new_data = JSON.parse(routing.body.read)
            new_dele = Delegate.new(new_data)
            raise('Could not save delegate') unless new_dele.save_changes

            response.status = 201
            response['Location'] = "#{@dele_route}/#{new_dele.id}"
            { message: 'Delegate saved', data: new_dele }.to_json
          rescue StandardError => e
            routing.halt 400, { message: e.message }.to_json
          end
        end
      end
    end
  end
end

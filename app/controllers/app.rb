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
        routing.on 'items' do
          @items_route = "#{@api_root}/items"

          routing.on String do |item_id|
            routing.on 'contacts' do
              @contacts_route = "#{@api_root}/items/#{item_id}/contacts"

              # GET /api/v1/items/:item_id/contacts/:contact_id
              routing.get String do |contact_id|
                contact = Contact.where(item_id: item_id, id: contact_id).first
                contact ? contact.to_json : raise('Contact not found')
              rescue StandardError
                routing.halt 500, { message: 'Server error' }.to_json
              end

              # GET /api/v1/items/:item_id/contacts
              routing.get do
                item = Item.first(id: item_id)
                raise 'Item not found' unless item

                output = { data: item.contacts }
                JSON.pretty_generate(output)
              rescue StandardError
                routing.halt 500, { message: 'Server error' }.to_json
              end

              # POST /api/v1/items/:item_id/contacts
              routing.post do
                new_data = JSON.parse(routing.body.read)
                item = Item.first(id: item_id)
                raise 'Item not found' unless item

                new_contact = item.new_contact(new_data)
                raise 'Could not save contact' unless new_contact

                response.status = 201
                response['Location'] = "#{@contacts_route}/#{new_contact.id}"
                { message: 'Contact saved', data: new_contact }.to_json
              rescue StandardError
                routing.halt 500, { message: 'Server error' }.to_json
              end
            end

            # GET /api/v1/items/:item_id
            routing.get do
              item = Item.first(id: item_id)
              item ? item.to_json : routing.halt(404, { message: 'Item not found' }.to_json)
            rescue StandardError
              routing.halt 500, { message: 'Server error' }.to_json
            end
          end

          # GET /api/v1/items
          routing.get do
            output = { data: Item.all }
            JSON.pretty_generate(output)
          end

          # POST /api/v1/items
          routing.post do
            new_data = JSON.parse(routing.body.read)
            new_data['type'] = new_data['type'].to_sym # Convert string to enum
            new_item = Item.new(new_data)
            raise 'Could not save item' unless new_item.save_changes

            response.status = 201
            response['Location'] = "#{@items_route}/#{new_item.id}"
            { message: 'Item saved', data: new_item }.to_json
          rescue StandardError
            routing.halt 500, { message: 'Server error' }.to_json
          end
        end
      end
    end
  end
end

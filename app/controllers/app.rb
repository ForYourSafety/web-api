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
        routing.on 'accounts' do
          @account_route = "#{@api_root}/accounts"

          routing.on String do |username|
            # GET api/v1/accounts/[username]
            routing.get do
              account = Account.first(username:)
              account ? account.to_json : routing.halt(404, { message: 'Account not found' }.to_json)
            rescue StandardError => e
              Api.logger.error "UNKOWN ERROR: #{e.message}"
              routing.halt 404, { message: 'Unknown server error' }.to_json
            end
          end

          # POST api/v1/accounts
          routing.post do
            new_data = JSON.parse(routing.body.read)
            new_account = Account.new(new_data)
            routing.halt 400, { message: 'Could not save account' }.to_json unless new_account.save_changes

            response.status = 201
            response['Location'] = "#{@account_route}/#{new_account.id}"
            { message: 'Account created', data: new_account }.to_json
          rescue Sequel::MassAssignmentRestriction
            Api.logger.warn "MASS-ASSIGNMENT:: #{new_data.keys}"
            routing.halt 400, { message: 'Illegal Request' }.to_json
          rescue StandardError => e
            Api.logger.error "UNKOWN ERROR: #{e.message}"
            routing.halt 500, { message: 'Unknown server error' }.to_json
          end
        end

        routing.on 'items' do
          @items_route = "#{@api_root}/items"

          routing.on String do |item_id|
            routing.on 'contacts' do
              @contacts_route = "#{@api_root}/items/#{item_id}/contacts"

              # GET /api/v1/items/:item_id/contacts/:contact_id
              routing.get String do |contact_id|
                contact = Contact.where(item_id: item_id, id: contact_id).first
                contact ? contact.to_json : routing.halt(404, { message: 'Contact not found' }.to_json)
              rescue StandardError => e
                Api.logger.error "UNKOWN ERROR: #{e.message}"
                routing.halt 500, { message: 'Unknown server error' }.to_json
              end

              # GET /api/v1/items/:item_id/contacts
              routing.get do
                item = Item.first(id: item_id)
                routing.halt 404, { message: 'Item not found' }.to_json unless item

                output = { data: item.contacts }
                JSON.pretty_generate(output)
              rescue StandardError => e
                Api.logger.error "UNKOWN ERROR: #{e.message}"
                routing.halt 500, { message: 'Unknown server error' }.to_json
              end

              # POST /api/v1/items/:item_id/contacts
              routing.post do
                new_data = JSON.parse(routing.body.read)
                item = Item.first(id: item_id)
                routing.halt 404, { message: 'Item not found' }.to_json unless item

                new_data['contact_type'] = new_data['contact_type'].to_sym # Convert string to enum
                new_contact = item.add_contact(new_data)
                routing.halt 400, { message: 'Could not save contact' }.to_json unless new_contact

                response.status = 201
                response['Location'] = "#{@contacts_route}/#{new_contact.id}"
                { message: 'Contact saved', data: new_contact }.to_json
              rescue Sequel::MassAssignmentRestriction
                Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
                routing.halt 400, { message: 'Illegal Attributes' }.to_json
              rescue StandardError => e
                Api.logger.error "UNKOWN ERROR: #{e.message}"
                routing.halt 500, { message: 'Unknown server error' }.to_json
              end
            end

            # GET /api/v1/items/:item_id
            routing.get do
              item = Item.first(id: item_id)
              item ? item.to_json : routing.halt(404, { message: 'Item not found' }.to_json)
            rescue StandardError => e
              Api.logger.error "UNKOWN ERROR: #{e.message}"
              routing.halt 500, { message: 'Unknown server error' }.to_json
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
            # TODO: temporarily use the first account as the owner
            # this should be replaced with the actual owner
            # once the authentication is implemented
            owner = Account.first
            new_item = CreateItemForOwner.call(
              owner_id: owner.id,
              item_data: new_data
            )
            routing.halt 400, { message: 'Could not save item' }.to_json unless new_item

            response.status = 201
            response['Location'] = "#{@items_route}/#{new_item.id}"
            { message: 'Item saved', data: new_item }.to_json
          rescue Sequel::MassAssignmentRestriction
            Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
            routing.halt 400, { message: 'Illegal Attributes' }.to_json
          rescue StandardError => e
            Api.logger.error "UNKOWN ERROR: #{e.message}"
            routing.halt 500, { message: 'Unknown server error' }.to_json
          end
        end
      end
    end
  end
end

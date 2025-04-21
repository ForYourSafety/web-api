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
        routing.on 'categories' do
          @cate_route = "#{@api_root}/categories"

          routing.on String do |cate_id|
            routing.on 'items' do
              @item_route = "#{@api_root}/categories/#{cate_id}/items"
              # GET api/v1/categories/[cate_id]/items/[item_id]
              routing.get String do |item_id|
                item = Item.where(category_id: cate_id, id: item_id).first
                item ? item.to_json : raise('item not found')
              rescue StandardError => e
                routing.halt 404, { message: e.message }.to_json
              end

              # GET api/v1/categories/[cate_id]/items
              routing.get do
                output = { data: Category.first(id: cate_id).items }
                JSON.pretty_generate(output)
              rescue StandardError
                routing.halt 404, message: 'Could not find documents'
              end

              # POST api/v1/categories/[ID]/items
              routing.post do
                new_data = JSON.parse(routing.body.read)
                cate = Category.first(id: cate_id)
                new_item = cate.add_item(new_data)

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

            # GET api/v1/categories/[ID]
            routing.get do
              cate = Category.first(id: cate_id)
              cate ? cate.to_json : raise('Category not found')
            rescue StandardError => e
              routing.halt 404, { message: e.message }.to_json
            end
          end

          # GET api/v1/categories
          routing.get do
            output = { data: Category.all }
            JSON.pretty_generate(output)
          rescue StandardError
            routing.halt 404, { message: 'Could not find categories' }.to_json
          end

          # POST api/v1/categories
          routing.post do
            new_data = JSON.parse(routing.body.read)
            new_cate = Category.new(new_data)
            raise('Could not save category') unless new_cate.save_changes

            response.status = 201
            response['Location'] = "#{@cate_route}/#{new_cate.id}"
            { message: 'Category saved', data: new_cate }.to_json
          rescue StandardError => e
            routing.halt 400, { message: e.message }.to_json
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

require_relative 'spec_helper'

describe 'Test Item Handling' do
  include Rack::Test::Methods

  before do
    wipe_database
  end

  it 'HAPPY: should be able to get list of all items' do
    DATA[:items].each do |item|
      item['type'] = item['type'].to_sym # Convert string to enum
      LostNFound::Item.create(item).save_changes
    end

    get 'api/v1/items'
    _(last_response.status).must_equal 200
    puts last_response.body

    result = JSON.parse last_response.body
    _(result['data'].count).must_equal 2
  end

  it 'HAPPY: should be able to get details of a single item' do
    item_data = DATA[:items][1]
    cate = LostNFound::Category.first
    item = cate.add_item(item_data).save # rubocop:disable Sequel/SaveChanges

    get "/api/v1/categories/#{cate.id}/items/#{item.id}"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data']['attributes']['id']).must_equal item.id
    _(result['data']['attributes']['itemname']).must_equal item_data['itemname']
  end

  it 'SAD: should return error if unknown document requested' do
    cate = LostNFound::Category.first
    get "/api/v1/categories/#{cate.id}/items/foobar"

    _(last_response.status).must_equal 404
  end

  it 'HAPPY: should be able to create new documents' do
    cate = LostNFound::Category.first
    item_data = DATA[:items][1]
    req_header = { 'CONTENT_TYPE' => 'application/json' }
    post "api/v1/categories/#{cate.id}/items",
         item_data.to_json, req_header
    _(last_response.status).must_equal 201
    _(last_response.headers['Location'].size).must_be :>, 0
    created = JSON.parse(last_response.body)['data']['data']['attributes']
    item = LostNFound::Item.first

    _(created['id']).must_equal item.id
    _(created['itemname']).must_equal item_data['itemname']
    _(created['description']).must_equal item_data['description']
  end
end

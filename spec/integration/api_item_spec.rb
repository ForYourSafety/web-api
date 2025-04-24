# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Item Handling' do
  include Rack::Test::Methods

  before do
    wipe_database
  end

  it 'HAPPY: should be able to get list of all items' do
    DATA[:items].each do |item|
      new_item = item.clone
      new_item['type'] = new_item['type'].to_sym # Convert string to enum
      LostNFound::Item.create(new_item).save_changes
    end

    get 'api/v1/items'
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data'].count).must_equal 2
  end

  it 'HAPPY: should be able to get details of a single item' do
    item_data = DATA[:items][1].clone
    item_data['type'] = item_data['type'].to_sym # Convert string to enum
    LostNFound::Item.create(item_data).save_changes
    item = LostNFound::Item.first

    get "/api/v1/items/#{item.id}"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data']['attributes']['id']).must_equal item.id
    _(result['data']['attributes']['name']).must_equal item_data['name']
    _(result['data']['attributes']['type'].to_sym).must_equal item_data['type']
  end

  it 'SAD: should return error if unknown item requested' do
    get '/api/v1/items/foobar'

    _(last_response.status).must_equal 404
  end

  describe 'Creating New Items' do
    before do
      @req_header = { 'CONTENT_TYPE' => 'application/json' }
      @item_data = DATA[:items][1]
    end

    it 'HAPPY: should be able to create new item' do
      post 'api/v1/items',
           @item_data.to_json, @req_header

      _(last_response.status).must_equal 201
      _(last_response.headers['Location'].size).must_be :>, 0
      created = JSON.parse(last_response.body)['data']['data']['attributes']
      item = LostNFound::Item.first

      _(created['id']).must_equal item.id
      _(created['name']).must_equal @item_data['name']
      _(created['type']).must_equal @item_data['type']
    end

    it 'SECURITY: should not create item with mass assignment' do
      bad_data = @item_data.clone
      bad_data['created_at'] = '1900-01-01'
      post 'api/v1/items', bad_data.to_json, @req_header

      _(last_response.status).must_equal 400
      _(last_response.headers['Location']).must_be_nil
    end
  end
end

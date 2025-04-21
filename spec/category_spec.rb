# frozen_string_literal: true

require_relative 'spec_helper'

describe 'Test Category Handling' do
  include Rack::Test::Methods

  before do
    wipe_database
  end

  it 'HAPPY: should be able to get list of all categories' do
    LostNFound::Category.create(DATA[:categories][0]).save_changes
    LostNFound::Category.create(DATA[:categories][1]).save_changes

    get 'api/v1/categories'
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data'].count).must_equal 2
  end

  it 'HAPPY: should be able to get details of a single category' do
    existing_cate = DATA[:categories][1]
    LostNFound::Category.create(existing_cate).save_changes
    id = LostNFound::Category.first.id

    get "/api/v1/categories/#{id}"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data']['attributes']['id']).must_equal id
    _(result['data']['attributes']['name']).must_equal existing_cate['name']
  end

  it 'SAD: should return error if unknown project requested' do
    get '/api/v1/categories/foobar'

    _(last_response.status).must_equal 404
  end

  it 'HAPPY: should be able to create new categories' do
    existing_cate = DATA[:categories][1]

    req_header = { 'CONTENT_TYPE' => 'application/json' }
    post 'api/v1/categories', existing_cate.to_json, req_header
    _(last_response.status).must_equal 201
    _(last_response.headers['Location'].size).must_be :>, 0

    created = JSON.parse(last_response.body)['data']['data']['attributes']
    cate = LostNFound::Category.first

    _(created['id']).must_equal cate.id
    _(created['name']).must_equal existing_cate['name']
    _(created['email']).must_equal existing_cate['email']
    _(created['phone_number']).must_equal existing_cate['phone_number']
  end
end

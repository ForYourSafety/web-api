# frozen_string_literal: true

require_relative 'spec_helper'

describe 'Test Delegate Handling' do
  include Rack::Test::Methods

  before do
    wipe_database
  end

  it 'HAPPY: should be able to get list of all delegates' do
    LostNFound::Delegate.create(DATA[:delegates][0]).save_changes
    LostNFound::Delegate.create(DATA[:delegates][1]).save_changes

    get 'api/v1/delegates'
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data'].count).must_equal 2
  end

  it 'HAPPY: should be able to get details of a single delegate' do
    existing_dele = DATA[:delegates][1]
    LostNFound::Delegate.create(existing_dele).save_changes
    id = LostNFound::Delegate.first.id

    get "/api/v1/delegates/#{id}"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data']['attributes']['id']).must_equal id
    _(result['data']['attributes']['name']).must_equal existing_dele['name']
  end

  it 'SAD: should return error if unknown project requested' do
    get '/api/v1/delegates/foobar'

    _(last_response.status).must_equal 404
  end

  it 'HAPPY: should be able to create new delegates' do
    existing_dele = DATA[:delegates][1]

    req_header = { 'CONTENT_TYPE' => 'application/json' }
    post 'api/v1/delegates', existing_dele.to_json, req_header
    _(last_response.status).must_equal 201
    _(last_response.headers['Location'].size).must_be :>, 0

    created = JSON.parse(last_response.body)['data']['data']['attributes']
    dele = LostNFound::Delegate.first

    _(created['id']).must_equal dele.id
    _(created['name']).must_equal existing_dele['name']
    _(created['email']).must_equal existing_dele['email']
    _(created['phone_number']).must_equal existing_dele['phone_number']
  end
end

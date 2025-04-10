# frozen_string_literal: true

require 'minitest/autorun'
require 'minitest/rg'
require 'rack/test'
require 'json'
require 'yaml'

require_relative '../app/controllers/app'
require_relative '../app/models/item'

def app
  LostNFound::Api
end

DATA = YAML.safe_load_file('app/db/seeds/item_seeds.yml')

describe 'Test LostNFound Web API' do
  include Rack::Test::Methods

  before do
    Dir.glob("#{LostNFound::Item::STORE_DIR}/*.json").each { |f| File.delete(f) }
    LostNFound::Item.setup
  end

  it 'should respond to root route' do
    get '/'
    _(last_response.status).must_equal 200
    _(JSON.parse(last_response.body)['message']).must_match(/LostNFound API/i)
  end
end

describe 'Handle fail item routes' do
  include Rack::Test::Methods

  before do
    Dir.glob("#{LostNFound::Item::STORE_DIR}/*.json").each { |f| File.delete(f) }
    LostNFound::Item.setup
  end

  it 'SAD: should return 404 when item not found' do
    get '/api/v1/item/nonexistent-id'
    _(last_response.status).must_equal 404
    _(JSON.parse(last_response.body)['message']).must_match(/not found/i)
  end
end

describe 'Handle 200 item routes' do
  include Rack::Test::Methods

  before do
    Dir.glob("#{LostNFound::Item::STORE_DIR}/*.json").each { |f| File.delete(f) }
    LostNFound::Item.setup
  end
  it 'HAPPY: should return list of all item UUIDs' do
    LostNFound::Item.new(DATA[0]).save
    LostNFound::Item.new(DATA[1]).save

    get '/api/v1/item'
    result = JSON.parse(last_response.body)

    _(last_response.status).must_equal 200
    _(result['item_ids'].size).must_equal 2
  end

  it 'HAPPY: should return details of a single item' do
    item = LostNFound::Item.new(DATA[0])
    item.save

    get "/api/v1/item/#{item.uuid}"
    result = JSON.parse(last_response.body)

    _(last_response.status).must_equal 200
    _(result['uuid']).must_equal item.uuid
    _(result['item_name']).must_equal 'Keys'
  end
end

describe 'Handle 201 item routes' do
  include Rack::Test::Methods

  before do
    Dir.glob("#{LostNFound::Item::STORE_DIR}/*.json").each { |f| File.delete(f) }
    LostNFound::Item.setup
  end

  it 'HAPPY: should create a new item' do
    header = { 'CONTENT_TYPE' => 'application/json' }
    post '/api/v1/item', DATA[0].to_json, header

    _(last_response.status).must_equal 201
    result = JSON.parse(last_response.body)
    _(result['message']).must_match(/saved/i)
    _(result['id']).wont_be_nil
  end
end

# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Contact Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    DATA[:items].each do |item|
      new_item = item.clone
      new_item['type'] = new_item['type'].to_sym # Convert string to enum
      LostNFound::Item.create(item).save_changes
    end
  end

  it 'HAPPY: should be able to get list of all contacts' do
    item = LostNFound::Item.first
    DATA[:contacts].each do |contact|
      new_contact = contact.clone
      new_contact['contact_type'] = new_contact['contact_type'].to_sym # Convert string to enum
      item.add_contact(new_contact)
    end

    get "api/v1/items/#{item.id}/contacts"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data'].count).must_equal DATA[:contacts].count
  end

  it 'HAPPY: should be able to get details of a single contact' do
    item = LostNFound::Item.first
    contact_data = DATA[:contacts][1].clone
    contact_data['contact_type'] = contact_data['contact_type'].to_sym # Convert string to enum
    item.add_contact(contact_data)
    contact = LostNFound::Contact.first

    get "/api/v1/items/#{item.id}/contacts/#{contact.id}"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data']['attributes']['id']).must_equal contact.id
    _(result['data']['attributes']['contact_type'].to_sym).must_equal contact_data['contact_type']
    _(result['data']['attributes']['value']).must_equal contact_data['value']
  end

  it 'SAD: should return error if unknown contact requested' do
    item = LostNFound::Item.first
    get "/api/v1/items/#{item.id}/contacts/foobar"

    _(last_response.status).must_equal 404
  end

  it 'HAPPY: should be able to create new contact' do
    item = LostNFound::Item.first
    contact_data = DATA[:contacts][0]
    req_header = { 'Content-Type' => 'application/json' }
    post "api/v1/items/#{item.id}/contacts",
         contact_data.to_json, req_header

    _(last_response.status).must_equal 201
    _(last_response.headers['Location'].size).must_be :>, 0
    created = JSON.parse(last_response.body)['data']['data']['attributes']
    contact = LostNFound::Contact.first

    _(created['id']).must_equal contact.id
    _(created['value']).must_equal contact_data['value']
    _(created['contact_type']).must_equal contact_data['contact_type']
  end
end

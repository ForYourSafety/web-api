# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Contact Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    @owner = LostNFound::Account.create(DATA[:accounts][0])
    @owner.save_changes

    DATA[:items].each do |item|
      LostNFound::CreateItemForOwner.call(
        owner_id: @owner.id,
        item_data: item
      )
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

  it 'SECURITY: should prevent basic SQL injection targeting IDs' do
    item = LostNFound::Item.first

    # Add contacts to the item
    DATA[:contacts].each do |contact|
      new_contact = contact.clone
      new_contact['contact_type'] = new_contact['contact_type'].to_sym # Convert string to enum
      item.add_contact(new_contact)
    end

    # Attempt SQL injection through contact_id
    injection_id = CGI.escape('2 or id>0') # encoded "2 or id>0"
    get "api/v1/items/#{item.id}/contacts/#{injection_id}"

    _(last_response.status).must_equal 404
    _(last_response.body['data']).must_be_nil
  end

  describe 'Creating Contacts' do
    before do
      @item = LostNFound::Item.first
      @contact_data = DATA[:contacts][1]
      @req_header = { 'CONTENT_TYPE' => 'application/json' }
    end

    it 'HAPPY: should be able to create new contact' do
      post "api/v1/items/#{@item.id}/contacts",
           @contact_data.to_json, @req_header

      _(last_response.status).must_equal 201
      _(last_response.headers['Location'].size).must_be :>, 0
      created = JSON.parse(last_response.body)['data']['data']['attributes']
      contact = LostNFound::Contact.first

      _(created['id']).must_equal contact.id
      _(created['value']).must_equal @contact_data['value']
      _(created['contact_type']).must_equal @contact_data['contact_type']
    end

    it 'SECURITY: should not create contacts with mass assignment' do
      bad_data = @contact_data.clone
      bad_data['created_at'] = '1900-01-01'
      post "api/v1/items/#{@item.id}/contacts",
           bad_data.to_json, @req_header

      _(last_response.status).must_equal 400
      _(last_response.headers['Location']).must_be_nil
    end
  end
end

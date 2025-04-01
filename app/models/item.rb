# frozen_string_literal: true

require 'json'
require 'securerandom'
require 'fileutils'

module LostNFound
  module ItemCategory
    LOST = 'LOST'
    FOUND = 'FOUND'
  end

  # A Lost or Found item
  class Item
    STORE_DIR = 'app/db/store/'

    # Create a new lost or found item instance
    def initialize(new_item)
      @uuid        = new_item['uuid'] || new_id
      @category    = new_item['category']
      @item_name   = new_item['item_name']
      @description = new_item['description'] || ''
      @datetime    = new_item['datetime'] || Time.now
      @location    = new_item['location'] || 'Unknown'
    end

    attr_reader :uuid, :category, :item_name, :description, :datetime, :location

    def to_json(options = {})
      {
        type: 'item',
        uuid: @uuid,
        category: @category,
        item_name: @item_name,
        description: @description,
        datetime: @datetime,
        location: @location
      }.to_json(options)
    end

    # File store must be setup once when application runs
    def self.setup
      FileUtils.mkdir_p(STORE_DIR) unless Dir.exist? STORE_DIR
    end

    # Stores items in the file store
    def save
      File.write("#{STORE_DIR}#{uuid}.json", to_json)
    end

    # Query method to find item by uuid
    def self.find(find_uuid)
      document_file = File.read("#{STORE_DIR}#{find_uuid}.json")
      Item.new JSON.parse(document_file)
    end

    # Query method to retrieve uuid of all items
    def self.all
      Dir.glob("#{STORE_DIR}*.json").map do |file|
        file.match(/#{Regexp.quote(STORE_DIR)}([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})\.json/)[1]
      end
    end

    private

    def new_id
      # Generate a new UUID
      SecureRandom.uuid
    end
  end
end

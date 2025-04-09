# frozen_string_literal: true

require 'minitest/autorun'
require 'fileutils'
require_relative '../app/models/item'

module LostNFound
  class TestItem < Minitest::Test
    def setup
      @store_dir = Item::STORE_DIR
      FileUtils.rm_rf(@store_dir)
      Item.setup

      @sample_data = {
        'category' => ItemCategory::LOST,
        'item_name' => 'Umbrella',
        'description' => 'Blue umbrella',
        'location' => 'Bus Station',
        'datetime' => '2025-04-09T10:00:00'
      }
    end

    def teardown
      FileUtils.rm_rf(@store_dir)
    end

    def test_initialize_with_data
      item = Item.new(@sample_data)
      assert_equal 'Umbrella', item.item_name
      assert_equal 'LOST', item.category
      assert_equal 'Bus Station', item.location
    end

    def test_generate_uuid_if_not_given
      item = Item.new(@sample_data)
      assert_match(/\A[0-9a-f\-]{36}\z/, item.uuid)
    end

    def test_save_and_find_item
      item = Item.new(@sample_data)
      item.save

      loaded = Item.find(item.uuid)
      assert_equal item.uuid, loaded.uuid
      assert_equal 'Blue umbrella', loaded.description
    end

    def test_all_returns_uuids
      3.times do |i|
        item = Item.new(@sample_data.merge('item_name' => "Item#{i}"))
        item.save
      end
      all_ids = Item.all
      assert_equal 3, all_ids.size
      all_ids.each { |uuid| assert_match(/\A[0-9a-f\-]{36}\z/, uuid) }
    end
  end
end

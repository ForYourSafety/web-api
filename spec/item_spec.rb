# frozen_string_literal: true

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'
require_relative '../app/models/item'

DATA = YAML.safe_load_file('app/db/seeds/item_seeds.yml')

describe 'LostNFound::Item initialization' do
  before do
    @data = DATA.first.dup
    @item = LostNFound::Item.new(@data)
  end

  it 'initializes with correct data' do
    _(@item.category).wont_be_nil
    _(@item.item_name).wont_be_nil
    _(@item.description).must_be_kind_of String
    _(@item.location).must_be_kind_of String
    _(@item.datetime).must_be_kind_of String
  end
end

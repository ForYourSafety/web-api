# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'

require_relative 'test_load_all'

def wipe_database
  app.DB[:items].delete
end

DATA = {} # rubocop:disable Style/MutableConstant
DATA[:items] = YAML.safe_load_file('db/seeds/item_seeds.yml')
DATA[:contacts] = YAML.safe_load_file('db/seeds/contact_seeds.yml')

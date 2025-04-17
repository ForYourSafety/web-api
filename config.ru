# frozen_string_literal: true

require './app/controllers/app'
require_app

run LostNFound::Api.freeze.app

# frozen_string_literal: true

require_relative "config_kit/version"
require_relative "config_kit/schema"
require_relative "config_kit/loader"
require_relative "config_kit/store"

module Philiprehberger
  module ConfigKit
    def self.define(yaml: nil, env: ENV, &block)
      Store.new(yaml: yaml, env: env, &block)
    end
  end
end

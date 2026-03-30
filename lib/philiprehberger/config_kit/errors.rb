# frozen_string_literal: true

module Philiprehberger
  module ConfigKit
    class Error < StandardError; end

    class MissingKeyError < Error
      attr_reader :key, :sources_checked

      def initialize(key, sources_checked)
        @key = key
        @sources_checked = sources_checked
        super("Required config key '#{key}' is missing. Sources checked: #{sources_checked.join(', ')}")
      end
    end
  end
end

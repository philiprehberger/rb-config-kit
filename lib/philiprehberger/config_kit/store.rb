# frozen_string_literal: true

module Philiprehberger
  module ConfigKit
    class Store
      attr_reader :schema

      def initialize(yaml: nil, env: ENV, &block)
        @schema = Schema.new
        @schema.instance_eval(&block) if block

        loader = Loader.new(@schema, yaml_path: yaml, env: env)
        @values = loader.load
        @values.freeze
        freeze
      end

      def get(key)
        @values[key]
      end

      alias [] get

      def to_h
        @values.dup
      end

      def keys
        @values.keys
      end

      def key?(key)
        @values.key?(key)
      end
    end
  end
end

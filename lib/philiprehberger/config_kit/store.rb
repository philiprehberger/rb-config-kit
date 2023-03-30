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
        @values[key.to_s.include?('.') ? key.to_s : key]
      end

      alias [] get

      def to_h
        build_nested_hash
      end

      def keys
        @values.keys
      end

      def key?(key)
        @values.key?(key.to_s.include?('.') ? key.to_s : key)
      end

      private

      def build_nested_hash
        result = {}
        @values.each do |key, value|
          parts = key.to_s.split('.')
          if parts.length > 1
            current = result
            parts[0..-2].each do |part|
              current[part] ||= {}
              current = current[part]
            end
            current[parts.last] = value
          else
            result[key] = value
          end
        end
        result
      end
    end
  end
end

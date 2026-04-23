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

      # Walks nested hash/array values using Ruby's standard +dig+ semantics.
      #
      # Fetches the top-level value via {#get} and, if additional keys are
      # provided and the value responds to +dig+, delegates to
      # +value.dig(*rest)+. Returns +nil+ when any intermediate key is missing.
      #
      # @param keys [Array<Symbol, String, Integer>] the sequence of keys to traverse
      # @return [Object, nil] the nested value, or +nil+ if any key along the path is missing
      # @raise [ArgumentError] if called with no arguments
      def dig(*keys)
        raise ArgumentError, 'wrong number of arguments (given 0, expected 1+)' if keys.empty?

        first, *rest = keys
        value = get(first)
        return value if rest.empty? || value.nil?

        value.respond_to?(:dig) ? value.dig(*rest) : nil
      end

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

# frozen_string_literal: true

require "yaml"

module Philiprehberger
  module ConfigKit
    class Loader
      def initialize(schema, yaml_path: nil, env: ENV)
        @schema = schema
        @yaml_path = yaml_path
        @env = env
      end

      def load
        values = {}

        @schema.definitions.each do |name, definition|
          value = resolve_value(name, definition)
          values[name] = cast(value, definition.type)
        end

        values
      end

      private

      def resolve_value(name, definition)
        # Layer 3: ENV override (highest priority)
        return @env[definition.env_key] if definition.env_key && @env.key?(definition.env_key)

        # Layer 2: YAML file
        yaml_value = yaml_data[name.to_s]
        return yaml_value unless yaml_value.nil?

        # Layer 1: Schema default (lowest priority)
        definition.default
      end

      def yaml_data
        @yaml_data ||= load_yaml
      end

      def load_yaml
        return {} unless @yaml_path && File.exist?(@yaml_path)

        data = YAML.safe_load_file(@yaml_path, permitted_classes: [Symbol])
        data.is_a?(Hash) ? data : {}
      end

      def cast(value, type)
        return nil if value.nil?

        case type
        when :string  then value.to_s
        when :integer then Integer(value)
        when :float   then Float(value)
        when :boolean then cast_boolean(value)
        end
      end

      def cast_boolean(value)
        case value
        when true, "true", "1", "yes" then true
        when false, "false", "0", "no" then false
        else !!value
        end
      end
    end
  end
end

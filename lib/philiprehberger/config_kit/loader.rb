# frozen_string_literal: true

require 'yaml'

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
          validate_required!(name, definition, value)
          values[name] = cast(value, definition.type, definition.element_type)
        end

        values
      end

      private

      def resolve_value(name, definition)
        case definition.type
        when :hash
          resolve_hash_value(name, definition)
        else
          resolve_scalar_value(name, definition)
        end
      end

      def resolve_scalar_value(name, definition)
        # Layer 3: ENV override (highest priority)
        env_key = definition.env_key
        return @env[env_key] if env_key && @env.key?(env_key)

        # Layer 2: YAML file
        yaml_value = dig_yaml(name)
        return yaml_value unless yaml_value.nil?

        # Layer 1: Schema default (lowest priority)
        definition.default
      end

      def resolve_hash_value(name, definition)
        # Layer 3: ENV — collect KEY_* pattern
        env_prefix = "#{definition.env_key}_"
        env_hash = {}
        @env.each do |k, v|
          if k.start_with?(env_prefix)
            sub_key = k[env_prefix.length..].downcase
            env_hash[sub_key] = v
          end
        end
        return env_hash unless env_hash.empty?

        # Layer 2: YAML file
        yaml_value = dig_yaml(name)
        return yaml_value if yaml_value.is_a?(Hash)

        # Layer 1: Schema default
        definition.default
      end

      def dig_yaml(name)
        parts = name.to_s.split('.')
        data = yaml_data
        parts.each do |part|
          return nil unless data.is_a?(Hash)

          data = data[part]
        end
        data
      end

      def validate_required!(name, definition, value)
        return unless definition.required
        return unless value.nil?

        sources = []
        sources << 'env' if definition.env_key
        sources << 'yaml' if @yaml_path
        sources << 'default'

        raise MissingKeyError.new(name, sources)
      end

      def yaml_data
        @yaml_data ||= load_yaml
      end

      def load_yaml
        return {} unless @yaml_path && File.exist?(@yaml_path)

        data = YAML.safe_load_file(@yaml_path, permitted_classes: [Symbol])
        data.is_a?(Hash) ? data : {}
      end

      def cast(value, type, element_type = nil)
        return nil if value.nil?

        case type
        when :string  then value.to_s
        when :integer then Integer(value)
        when :float   then Float(value)
        when :boolean then cast_boolean(value)
        when :array   then cast_array(value, element_type)
        when :hash    then cast_hash(value)
        end
      end

      def cast_boolean(value)
        case value
        when true, 'true', '1', 'yes' then true
        when false, 'false', '0', 'no' then false
        else !!value
        end
      end

      def cast_array(value, element_type)
        items = value.is_a?(Array) ? value : value.to_s.split(',').map(&:strip)
        items.map { |item| cast(item, element_type || :string) }
      end

      def cast_hash(value)
        return {} unless value.is_a?(Hash)

        value.transform_keys(&:to_s)
      end
    end
  end
end

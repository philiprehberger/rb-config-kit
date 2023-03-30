# frozen_string_literal: true

module Philiprehberger
  module ConfigKit
    class Schema
      Definition = Struct.new(:name, :type, :default, :env_key, :required, :element_type, keyword_init: true)

      attr_reader :definitions

      def initialize
        @definitions = {}
      end

      def string(name, default: nil, env: nil)
        add_definition(name, :string, default, env)
      end

      def integer(name, default: nil, env: nil)
        add_definition(name, :integer, default, env)
      end

      def boolean(name, default: nil, env: nil)
        add_definition(name, :boolean, default, env)
      end

      def float(name, default: nil, env: nil)
        add_definition(name, :float, default, env)
      end

      def array(name, of: :string, default: nil, env: nil)
        add_definition(name, :array, default, env, element_type: of)
      end

      def hash_type(name, default: nil, env: nil)
        add_definition(name, :hash, default, env)
      end

      def required(name, type:, env: nil)
        add_definition(name, type, nil, env, required: true)
      end

      private

      def add_definition(name, type, default, env_key, required: false, element_type: nil)
        resolved_env_key = env_key || default_env_key(name)
        @definitions[name] = Definition.new(
          name: name,
          type: type,
          default: default,
          env_key: resolved_env_key,
          required: required,
          element_type: element_type
        )
      end

      def default_env_key(name)
        name.to_s.tr('.', '_').upcase
      end
    end
  end
end

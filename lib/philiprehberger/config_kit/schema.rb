# frozen_string_literal: true

module Philiprehberger
  module ConfigKit
    class Schema
      Definition = Struct.new(:name, :type, :default, :env_key, keyword_init: true)

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

      private

      def add_definition(name, type, default, env_key)
        @definitions[name] = Definition.new(
          name: name,
          type: type,
          default: default,
          env_key: env_key
        )
      end
    end
  end
end

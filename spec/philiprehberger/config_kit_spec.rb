# frozen_string_literal: true

require "spec_helper"
require "tempfile"
require "yaml"

RSpec.describe Philiprehberger::ConfigKit do
  describe ".define" do
    it "returns a Store instance" do
      config = described_class.define do
        string :name, default: "test"
      end

      expect(config).to be_a(Philiprehberger::ConfigKit::Store)
    end
  end

  describe "defaults" do
    it "resolves string defaults" do
      config = described_class.define(env: {}) do
        string :app_name, default: "my-app"
      end

      expect(config[:app_name]).to eq("my-app")
    end

    it "resolves integer defaults" do
      config = described_class.define(env: {}) do
        integer :port, default: 3000
      end

      expect(config[:port]).to eq(3000)
    end

    it "resolves boolean defaults" do
      config = described_class.define(env: {}) do
        boolean :debug, default: false
      end

      expect(config[:debug]).to eq(false)
    end

    it "resolves float defaults" do
      config = described_class.define(env: {}) do
        float :rate, default: 0.75
      end

      expect(config[:rate]).to eq(0.75)
    end

    it "returns nil for keys with no default" do
      config = described_class.define(env: {}) do
        string :optional
      end

      expect(config[:optional]).to be_nil
    end
  end

  describe "YAML loading" do
    it "loads values from a YAML file" do
      yaml_file = Tempfile.new(["config", ".yml"])
      yaml_file.write(YAML.dump("app_name" => "yaml-app", "port" => 8080))
      yaml_file.close

      config = described_class.define(yaml: yaml_file.path, env: {}) do
        string :app_name, default: "default-app"
        integer :port, default: 3000
      end

      expect(config[:app_name]).to eq("yaml-app")
      expect(config[:port]).to eq(8080)
    ensure
      yaml_file&.unlink
    end

    it "falls back to defaults when YAML key is missing" do
      yaml_file = Tempfile.new(["config", ".yml"])
      yaml_file.write(YAML.dump("app_name" => "yaml-app"))
      yaml_file.close

      config = described_class.define(yaml: yaml_file.path, env: {}) do
        string :app_name, default: "default-app"
        integer :port, default: 3000
      end

      expect(config[:app_name]).to eq("yaml-app")
      expect(config[:port]).to eq(3000)
    ensure
      yaml_file&.unlink
    end

    it "handles missing YAML file gracefully" do
      config = described_class.define(yaml: "/nonexistent/config.yml", env: {}) do
        string :app_name, default: "default-app"
      end

      expect(config[:app_name]).to eq("default-app")
    end
  end

  describe "ENV overrides" do
    it "overrides defaults with ENV values" do
      env = { "APP_PORT" => "9090" }

      config = described_class.define(env: env) do
        integer :port, default: 3000, env: "APP_PORT"
      end

      expect(config[:port]).to eq(9090)
    end

    it "overrides YAML values with ENV values" do
      yaml_file = Tempfile.new(["config", ".yml"])
      yaml_file.write(YAML.dump("port" => 8080))
      yaml_file.close

      env = { "APP_PORT" => "9090" }

      config = described_class.define(yaml: yaml_file.path, env: env) do
        integer :port, default: 3000, env: "APP_PORT"
      end

      expect(config[:port]).to eq(9090)
    ensure
      yaml_file&.unlink
    end

    it "ignores ENV when the variable is not set" do
      config = described_class.define(env: {}) do
        string :name, default: "fallback", env: "APP_NAME"
      end

      expect(config[:name]).to eq("fallback")
    end
  end

  describe "type casting" do
    it "casts string from ENV" do
      config = described_class.define(env: { "VAL" => "hello" }) do
        string :val, env: "VAL"
      end

      expect(config[:val]).to eq("hello")
      expect(config[:val]).to be_a(String)
    end

    it "casts integer from ENV" do
      config = described_class.define(env: { "VAL" => "42" }) do
        integer :val, env: "VAL"
      end

      expect(config[:val]).to eq(42)
      expect(config[:val]).to be_a(Integer)
    end

    it "casts float from ENV" do
      config = described_class.define(env: { "VAL" => "3.14" }) do
        float :val, env: "VAL"
      end

      expect(config[:val]).to eq(3.14)
      expect(config[:val]).to be_a(Float)
    end

    it "casts boolean 'true' from ENV" do
      config = described_class.define(env: { "VAL" => "true" }) do
        boolean :val, env: "VAL"
      end

      expect(config[:val]).to eq(true)
    end

    it "casts boolean 'false' from ENV" do
      config = described_class.define(env: { "VAL" => "false" }) do
        boolean :val, env: "VAL"
      end

      expect(config[:val]).to eq(false)
    end

    it "casts boolean '1' as true" do
      config = described_class.define(env: { "VAL" => "1" }) do
        boolean :val, env: "VAL"
      end

      expect(config[:val]).to eq(true)
    end

    it "casts boolean '0' as false" do
      config = described_class.define(env: { "VAL" => "0" }) do
        boolean :val, env: "VAL"
      end

      expect(config[:val]).to eq(false)
    end
  end

  describe "Store" do
    subject(:config) do
      described_class.define(env: {}) do
        string :name, default: "app"
        integer :port, default: 3000
      end
    end

    it "supports #get" do
      expect(config.get(:name)).to eq("app")
    end

    it "supports #[] accessor" do
      expect(config[:port]).to eq(3000)
    end

    it "exports all values with #to_h" do
      expect(config.to_h).to eq({ name: "app", port: 3000 })
    end

    it "lists all keys" do
      expect(config.keys).to contain_exactly(:name, :port)
    end

    it "checks key existence" do
      expect(config.key?(:name)).to be(true)
      expect(config.key?(:missing)).to be(false)
    end

    it "is frozen after creation" do
      expect(config).to be_frozen
    end

    it "returns nil for undefined keys" do
      expect(config[:nonexistent]).to be_nil
    end

    it "to_h returns independent copy" do
      h1 = config.to_h
      h2 = config.to_h
      expect(h1).not_to be(h2)
      expect(h1).to eq(h2)
    end
  end

  describe "type casting" do
    it "casts boolean 'yes' as true" do
      config = described_class.define(env: { "VAL" => "yes" }) do
        boolean :val, env: "VAL"
      end

      expect(config[:val]).to eq(true)
    end

    it "casts boolean 'no' as false" do
      config = described_class.define(env: { "VAL" => "no" }) do
        boolean :val, env: "VAL"
      end

      expect(config[:val]).to eq(false)
    end

    it "casts non-standard boolean values with double-bang" do
      config = described_class.define(env: { "VAL" => "anything" }) do
        boolean :val, env: "VAL"
      end

      expect(config[:val]).to eq(true)
    end

    it "casts integer from YAML" do
      yaml_file = Tempfile.new(["config", ".yml"])
      yaml_file.write(YAML.dump("count" => 42))
      yaml_file.close

      config = described_class.define(yaml: yaml_file.path, env: {}) do
        integer :count
      end

      expect(config[:count]).to eq(42)
    ensure
      yaml_file&.unlink
    end

    it "casts float from YAML" do
      yaml_file = Tempfile.new(["config", ".yml"])
      yaml_file.write(YAML.dump("rate" => 0.5))
      yaml_file.close

      config = described_class.define(yaml: yaml_file.path, env: {}) do
        float :rate
      end

      expect(config[:rate]).to eq(0.5)
    ensure
      yaml_file&.unlink
    end
  end

  describe "layer precedence" do
    it "ENV > YAML > defaults (full stack)" do
      yaml_file = Tempfile.new(["config", ".yml"])
      yaml_file.write(YAML.dump("name" => "yaml-val"))
      yaml_file.close

      config = described_class.define(yaml: yaml_file.path, env: { "APP_NAME" => "env-val" }) do
        string :name, default: "default-val", env: "APP_NAME"
      end

      expect(config[:name]).to eq("env-val")
    ensure
      yaml_file&.unlink
    end

    it "YAML > defaults when ENV not set" do
      yaml_file = Tempfile.new(["config", ".yml"])
      yaml_file.write(YAML.dump("name" => "yaml-val"))
      yaml_file.close

      config = described_class.define(yaml: yaml_file.path, env: {}) do
        string :name, default: "default-val", env: "APP_NAME"
      end

      expect(config[:name]).to eq("yaml-val")
    ensure
      yaml_file&.unlink
    end
  end

  describe "multiple definitions" do
    it "supports many keys of mixed types" do
      config = described_class.define(env: {}) do
        string :name, default: "app"
        integer :port, default: 3000
        boolean :debug, default: false
        float :rate, default: 1.5
      end

      expect(config.keys).to contain_exactly(:name, :port, :debug, :rate)
      expect(config[:name]).to eq("app")
      expect(config[:port]).to eq(3000)
      expect(config[:debug]).to eq(false)
      expect(config[:rate]).to eq(1.5)
    end
  end

  describe "YAML edge cases" do
    it "handles YAML file with non-hash root" do
      yaml_file = Tempfile.new(["config", ".yml"])
      yaml_file.write(YAML.dump("just a string"))
      yaml_file.close

      config = described_class.define(yaml: yaml_file.path, env: {}) do
        string :name, default: "fallback"
      end

      expect(config[:name]).to eq("fallback")
    ensure
      yaml_file&.unlink
    end
  end
end

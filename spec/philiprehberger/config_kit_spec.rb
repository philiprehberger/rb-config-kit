# frozen_string_literal: true

require 'spec_helper'
require 'tempfile'
require 'yaml'

RSpec.describe Philiprehberger::ConfigKit do
  describe '.define' do
    it 'returns a Store instance' do
      config = described_class.define do
        string :name, default: 'test'
      end

      expect(config).to be_a(Philiprehberger::ConfigKit::Store)
    end
  end

  describe 'defaults' do
    it 'resolves string defaults' do
      config = described_class.define(env: {}) do
        string :app_name, default: 'my-app'
      end

      expect(config[:app_name]).to eq('my-app')
    end

    it 'resolves integer defaults' do
      config = described_class.define(env: {}) do
        integer :port, default: 3000
      end

      expect(config[:port]).to eq(3000)
    end

    it 'resolves boolean defaults' do
      config = described_class.define(env: {}) do
        boolean :debug, default: false
      end

      expect(config[:debug]).to eq(false)
    end

    it 'resolves float defaults' do
      config = described_class.define(env: {}) do
        float :rate, default: 0.75
      end

      expect(config[:rate]).to eq(0.75)
    end

    it 'returns nil for keys with no default' do
      config = described_class.define(env: {}) do
        string :optional
      end

      expect(config[:optional]).to be_nil
    end
  end

  describe 'YAML loading' do
    it 'loads values from a YAML file' do
      yaml_file = Tempfile.new(['config', '.yml'])
      yaml_file.write(YAML.dump('app_name' => 'yaml-app', 'port' => 8080))
      yaml_file.close

      config = described_class.define(yaml: yaml_file.path, env: {}) do
        string :app_name, default: 'default-app'
        integer :port, default: 3000
      end

      expect(config[:app_name]).to eq('yaml-app')
      expect(config[:port]).to eq(8080)
    ensure
      yaml_file&.unlink
    end

    it 'falls back to defaults when YAML key is missing' do
      yaml_file = Tempfile.new(['config', '.yml'])
      yaml_file.write(YAML.dump('app_name' => 'yaml-app'))
      yaml_file.close

      config = described_class.define(yaml: yaml_file.path, env: {}) do
        string :app_name, default: 'default-app'
        integer :port, default: 3000
      end

      expect(config[:app_name]).to eq('yaml-app')
      expect(config[:port]).to eq(3000)
    ensure
      yaml_file&.unlink
    end

    it 'handles missing YAML file gracefully' do
      config = described_class.define(yaml: '/nonexistent/config.yml', env: {}) do
        string :app_name, default: 'default-app'
      end

      expect(config[:app_name]).to eq('default-app')
    end
  end

  describe 'ENV overrides' do
    it 'overrides defaults with ENV values' do
      env = { 'APP_PORT' => '9090' }

      config = described_class.define(env: env) do
        integer :port, default: 3000, env: 'APP_PORT'
      end

      expect(config[:port]).to eq(9090)
    end

    it 'overrides YAML values with ENV values' do
      yaml_file = Tempfile.new(['config', '.yml'])
      yaml_file.write(YAML.dump('port' => 8080))
      yaml_file.close

      env = { 'APP_PORT' => '9090' }

      config = described_class.define(yaml: yaml_file.path, env: env) do
        integer :port, default: 3000, env: 'APP_PORT'
      end

      expect(config[:port]).to eq(9090)
    ensure
      yaml_file&.unlink
    end

    it 'ignores ENV when the variable is not set' do
      config = described_class.define(env: {}) do
        string :name, default: 'fallback', env: 'APP_NAME'
      end

      expect(config[:name]).to eq('fallback')
    end
  end

  describe 'type casting' do
    it 'casts string from ENV' do
      config = described_class.define(env: { 'VAL' => 'hello' }) do
        string :val, env: 'VAL'
      end

      expect(config[:val]).to eq('hello')
      expect(config[:val]).to be_a(String)
    end

    it 'casts integer from ENV' do
      config = described_class.define(env: { 'VAL' => '42' }) do
        integer :val, env: 'VAL'
      end

      expect(config[:val]).to eq(42)
      expect(config[:val]).to be_a(Integer)
    end

    it 'casts float from ENV' do
      config = described_class.define(env: { 'VAL' => '3.14' }) do
        float :val, env: 'VAL'
      end

      expect(config[:val]).to eq(3.14)
      expect(config[:val]).to be_a(Float)
    end

    it "casts boolean 'true' from ENV" do
      config = described_class.define(env: { 'VAL' => 'true' }) do
        boolean :val, env: 'VAL'
      end

      expect(config[:val]).to eq(true)
    end

    it "casts boolean 'false' from ENV" do
      config = described_class.define(env: { 'VAL' => 'false' }) do
        boolean :val, env: 'VAL'
      end

      expect(config[:val]).to eq(false)
    end

    it "casts boolean '1' as true" do
      config = described_class.define(env: { 'VAL' => '1' }) do
        boolean :val, env: 'VAL'
      end

      expect(config[:val]).to eq(true)
    end

    it "casts boolean '0' as false" do
      config = described_class.define(env: { 'VAL' => '0' }) do
        boolean :val, env: 'VAL'
      end

      expect(config[:val]).to eq(false)
    end

    it "casts boolean 'yes' as true" do
      config = described_class.define(env: { 'VAL' => 'yes' }) do
        boolean :val, env: 'VAL'
      end

      expect(config[:val]).to eq(true)
    end

    it "casts boolean 'no' as false" do
      config = described_class.define(env: { 'VAL' => 'no' }) do
        boolean :val, env: 'VAL'
      end

      expect(config[:val]).to eq(false)
    end

    it 'casts non-standard boolean values with double-bang' do
      config = described_class.define(env: { 'VAL' => 'anything' }) do
        boolean :val, env: 'VAL'
      end

      expect(config[:val]).to eq(true)
    end

    it 'casts integer from YAML' do
      yaml_file = Tempfile.new(['config', '.yml'])
      yaml_file.write(YAML.dump('count' => 42))
      yaml_file.close

      config = described_class.define(yaml: yaml_file.path, env: {}) do
        integer :count
      end

      expect(config[:count]).to eq(42)
    ensure
      yaml_file&.unlink
    end

    it 'casts float from YAML' do
      yaml_file = Tempfile.new(['config', '.yml'])
      yaml_file.write(YAML.dump('rate' => 0.5))
      yaml_file.close

      config = described_class.define(yaml: yaml_file.path, env: {}) do
        float :rate
      end

      expect(config[:rate]).to eq(0.5)
    ensure
      yaml_file&.unlink
    end
  end

  describe 'Store' do
    subject(:config) do
      described_class.define(env: {}) do
        string :name, default: 'app'
        integer :port, default: 3000
      end
    end

    it 'supports #get' do
      expect(config.get(:name)).to eq('app')
    end

    it 'supports #[] accessor' do
      expect(config[:port]).to eq(3000)
    end

    it 'exports all values with #to_h' do
      expect(config.to_h).to eq({ name: 'app', port: 3000 })
    end

    it 'lists all keys' do
      expect(config.keys).to contain_exactly(:name, :port)
    end

    it 'checks key existence' do
      expect(config.key?(:name)).to be(true)
      expect(config.key?(:missing)).to be(false)
    end

    it 'is frozen after creation' do
      expect(config).to be_frozen
    end

    it 'returns nil for undefined keys' do
      expect(config[:nonexistent]).to be_nil
    end

    it 'to_h returns independent copy' do
      h1 = config.to_h
      h2 = config.to_h
      expect(h1).not_to be(h2)
      expect(h1).to eq(h2)
    end

    describe '#dig' do
      it 'returns the top-level value when given a single key' do
        store = described_class.define(env: {}) do
          integer :port, default: 3000
        end

        expect(store[:port]).to eq(3000)
      end

      it 'walks nested hashes' do
        yaml_file = Tempfile.new(['config', '.yml'])
        yaml_file.write(YAML.dump('database' => { 'host' => 'localhost', 'port' => 5432 }))
        yaml_file.close

        store = described_class.define(yaml: yaml_file.path, env: {}) do
          hash_type :database
        end

        expect(store.dig(:database, 'host')).to eq('localhost')
        expect(store.dig(:database, 'port')).to eq(5432)
      ensure
        yaml_file&.unlink
      end

      it 'returns nil when an intermediate key is missing' do
        yaml_file = Tempfile.new(['config', '.yml'])
        yaml_file.write(YAML.dump('database' => { 'host' => 'localhost' }))
        yaml_file.close

        store = described_class.define(yaml: yaml_file.path, env: {}) do
          hash_type :database
        end

        expect(store.dig(:database, 'missing')).to be_nil
      ensure
        yaml_file&.unlink
      end

      it 'returns nil when the top-level key is missing' do
        store = described_class.define(env: {}) do
          string :name, default: 'app'
        end

        expect(store[:missing]).to be_nil
        expect(store.dig(:missing, :deeper)).to be_nil
      end

      it 'walks through arrays with integer indices' do
        yaml_file = Tempfile.new(['config', '.yml'])
        yaml_file.write(YAML.dump('servers' => { 'hosts' => [{ 'name' => 'web-1' }, { 'name' => 'web-2' }] }))
        yaml_file.close

        store = described_class.define(yaml: yaml_file.path, env: {}) do
          hash_type :servers
        end

        expect(store.dig(:servers, 'hosts', 0, 'name')).to eq('web-1')
        expect(store.dig(:servers, 'hosts', 1, 'name')).to eq('web-2')
      ensure
        yaml_file&.unlink
      end

      it 'raises ArgumentError when called with no arguments' do
        store = described_class.define(env: {}) do
          string :name, default: 'app'
        end

        expect { store.dig }.to raise_error(ArgumentError)
      end
    end
  end

  describe 'layer precedence' do
    it 'ENV > YAML > defaults (full stack)' do
      yaml_file = Tempfile.new(['config', '.yml'])
      yaml_file.write(YAML.dump('name' => 'yaml-val'))
      yaml_file.close

      config = described_class.define(yaml: yaml_file.path, env: { 'APP_NAME' => 'env-val' }) do
        string :name, default: 'default-val', env: 'APP_NAME'
      end

      expect(config[:name]).to eq('env-val')
    ensure
      yaml_file&.unlink
    end

    it 'YAML > defaults when ENV not set' do
      yaml_file = Tempfile.new(['config', '.yml'])
      yaml_file.write(YAML.dump('name' => 'yaml-val'))
      yaml_file.close

      config = described_class.define(yaml: yaml_file.path, env: {}) do
        string :name, default: 'default-val', env: 'APP_NAME'
      end

      expect(config[:name]).to eq('yaml-val')
    ensure
      yaml_file&.unlink
    end
  end

  describe 'multiple definitions' do
    it 'supports many keys of mixed types' do
      config = described_class.define(env: {}) do
        string :name, default: 'app'
        integer :port, default: 3000
        boolean :debug, default: false
        float :rate, default: 1.5
      end

      expect(config.keys).to contain_exactly(:name, :port, :debug, :rate)
      expect(config[:name]).to eq('app')
      expect(config[:port]).to eq(3000)
      expect(config[:debug]).to eq(false)
      expect(config[:rate]).to eq(1.5)
    end
  end

  describe 'YAML edge cases' do
    it 'handles YAML file with non-hash root' do
      yaml_file = Tempfile.new(['config', '.yml'])
      yaml_file.write(YAML.dump('just a string'))
      yaml_file.close

      config = described_class.define(yaml: yaml_file.path, env: {}) do
        string :name, default: 'fallback'
      end

      expect(config[:name]).to eq('fallback')
    ensure
      yaml_file&.unlink
    end
  end

  describe 'nested configuration' do
    it 'supports dot-notation keys with defaults' do
      config = described_class.define(env: {}) do
        string 'database.host', default: 'localhost'
        integer 'database.port', default: 5432
      end

      expect(config.get('database.host')).to eq('localhost')
      expect(config['database.port']).to eq(5432)
    end

    it 'loads nested keys from YAML' do
      yaml_file = Tempfile.new(['config', '.yml'])
      yaml_file.write(YAML.dump('database' => { 'host' => 'db.example.com', 'port' => 3306 }))
      yaml_file.close

      config = described_class.define(yaml: yaml_file.path, env: {}) do
        string 'database.host', default: 'localhost'
        integer 'database.port', default: 5432
      end

      expect(config['database.host']).to eq('db.example.com')
      expect(config['database.port']).to eq(3306)
    ensure
      yaml_file&.unlink
    end

    it 'maps dot-notation keys to uppercase ENV with underscores' do
      env = { 'DATABASE_HOST' => 'env-host', 'DATABASE_PORT' => '9999' }

      config = described_class.define(env: env) do
        string 'database.host', default: 'localhost'
        integer 'database.port', default: 5432
      end

      expect(config['database.host']).to eq('env-host')
      expect(config['database.port']).to eq(9999)
    end

    it 'allows custom env key override for nested keys' do
      env = { 'MY_DB_HOST' => 'custom-host' }

      config = described_class.define(env: env) do
        string 'database.host', default: 'localhost', env: 'MY_DB_HOST'
      end

      expect(config['database.host']).to eq('custom-host')
    end

    it 'returns nested hash from to_h' do
      config = described_class.define(env: {}) do
        string 'database.host', default: 'localhost'
        integer 'database.port', default: 5432
        string :app_name, default: 'my-app'
      end

      expected = {
        'database' => { 'host' => 'localhost', 'port' => 5432 },
        app_name: 'my-app'
      }
      expect(config.to_h).to eq(expected)
    end

    it 'supports deeply nested keys' do
      config = described_class.define(env: {}) do
        string 'services.database.primary.host', default: 'deep-host'
      end

      expect(config['services.database.primary.host']).to eq('deep-host')
      expect(config.to_h).to eq({ 'services' => { 'database' => { 'primary' => { 'host' => 'deep-host' } } } })
    end

    it 'supports key? for nested keys' do
      config = described_class.define(env: {}) do
        string 'database.host', default: 'localhost'
      end

      expect(config.key?('database.host')).to be(true)
      expect(config.key?('database.missing')).to be(false)
    end

    it 'ENV overrides YAML for nested keys' do
      yaml_file = Tempfile.new(['config', '.yml'])
      yaml_file.write(YAML.dump('database' => { 'host' => 'yaml-host' }))
      yaml_file.close

      env = { 'DATABASE_HOST' => 'env-host' }

      config = described_class.define(yaml: yaml_file.path, env: env) do
        string 'database.host', default: 'default-host'
      end

      expect(config['database.host']).to eq('env-host')
    ensure
      yaml_file&.unlink
    end
  end

  describe 'array type' do
    it 'splits ENV values by comma' do
      env = { 'TAGS' => 'ruby,web,api' }

      config = described_class.define(env: env) do
        array :tags, of: :string, env: 'TAGS'
      end

      expect(config[:tags]).to eq(%w[ruby web api])
    end

    it 'coerces array elements to the specified type' do
      env = { 'PORTS' => '3000,4000,5000' }

      config = described_class.define(env: env) do
        array :ports, of: :integer, env: 'PORTS'
      end

      expect(config[:ports]).to eq([3000, 4000, 5000])
    end

    it 'coerces array elements to float' do
      env = { 'RATES' => '1.5,2.5,3.5' }

      config = described_class.define(env: env) do
        array :rates, of: :float, env: 'RATES'
      end

      expect(config[:rates]).to eq([1.5, 2.5, 3.5])
    end

    it 'coerces array elements to boolean' do
      env = { 'FLAGS' => 'true,false,1,0,yes' }

      config = described_class.define(env: env) do
        array :flags, of: :boolean, env: 'FLAGS'
      end

      expect(config[:flags]).to eq([true, false, true, false, true])
    end

    it 'passes YAML arrays through directly' do
      yaml_file = Tempfile.new(['config', '.yml'])
      yaml_file.write(YAML.dump('tags' => %w[alpha beta gamma]))
      yaml_file.close

      config = described_class.define(yaml: yaml_file.path, env: {}) do
        array :tags, of: :string
      end

      expect(config[:tags]).to eq(%w[alpha beta gamma])
    ensure
      yaml_file&.unlink
    end

    it 'uses default array value when no source provides one' do
      config = described_class.define(env: {}) do
        array :tags, of: :string, default: %w[default1 default2]
      end

      expect(config[:tags]).to eq(%w[default1 default2])
    end

    it 'returns nil for array with no value and no default' do
      config = described_class.define(env: {}) do
        array :tags, of: :string
      end

      expect(config[:tags]).to be_nil
    end

    it 'strips whitespace around comma-separated ENV values' do
      env = { 'TAGS' => ' ruby , web , api ' }

      config = described_class.define(env: env) do
        array :tags, of: :string, env: 'TAGS'
      end

      expect(config[:tags]).to eq(%w[ruby web api])
    end

    it 'defaults element type to string' do
      env = { 'ITEMS' => 'a,b,c' }

      config = described_class.define(env: env) do
        array :items, env: 'ITEMS'
      end

      expect(config[:items]).to eq(%w[a b c])
    end

    it 'coerces YAML integer arrays to specified type' do
      yaml_file = Tempfile.new(['config', '.yml'])
      yaml_file.write(YAML.dump('ports' => [3000, 4000, 5000]))
      yaml_file.close

      config = described_class.define(yaml: yaml_file.path, env: {}) do
        array :ports, of: :integer
      end

      expect(config[:ports]).to eq([3000, 4000, 5000])
    ensure
      yaml_file&.unlink
    end
  end

  describe 'hash type' do
    it 'collects ENV vars matching KEY_* pattern into a hash' do
      env = { 'REDIS_HOST' => 'localhost', 'REDIS_PORT' => '6379', 'REDIS_DB' => '0', 'OTHER_KEY' => 'ignored' }

      config = described_class.define(env: env) do
        hash_type :redis, env: 'REDIS'
      end

      expect(config[:redis]).to eq({ 'host' => 'localhost', 'port' => '6379', 'db' => '0' })
    end

    it 'loads hash from YAML directly' do
      yaml_file = Tempfile.new(['config', '.yml'])
      yaml_file.write(YAML.dump('redis' => { 'host' => 'yaml-host', 'port' => 6380 }))
      yaml_file.close

      config = described_class.define(yaml: yaml_file.path, env: {}) do
        hash_type :redis
      end

      expect(config[:redis]).to eq({ 'host' => 'yaml-host', 'port' => 6380 })
    ensure
      yaml_file&.unlink
    end

    it 'uses default hash value when no source provides one' do
      config = described_class.define(env: {}) do
        hash_type :redis, default: { 'host' => 'default-host' }
      end

      expect(config[:redis]).to eq({ 'host' => 'default-host' })
    end

    it 'returns nil for hash with no value and no default' do
      config = described_class.define(env: {}) do
        hash_type :redis
      end

      expect(config[:redis]).to be_nil
    end

    it 'ENV hash takes precedence over YAML hash' do
      yaml_file = Tempfile.new(['config', '.yml'])
      yaml_file.write(YAML.dump('redis' => { 'host' => 'yaml-host' }))
      yaml_file.close

      env = { 'REDIS_HOST' => 'env-host', 'REDIS_PORT' => '6379' }

      config = described_class.define(yaml: yaml_file.path, env: env) do
        hash_type :redis, env: 'REDIS'
      end

      expect(config[:redis]).to eq({ 'host' => 'env-host', 'port' => '6379' })
    ensure
      yaml_file&.unlink
    end

    it 'lowercases the sub-keys from ENV' do
      env = { 'REDIS_MAX_CONNECTIONS' => '10' }

      config = described_class.define(env: env) do
        hash_type :redis, env: 'REDIS'
      end

      expect(config[:redis]).to eq({ 'max_connections' => '10' })
    end
  end

  describe 'required key validation' do
    it 'raises MissingKeyError when required key has no value' do
      expect do
        described_class.define(env: {}) do
          required :api_key, type: :string
        end
      end.to raise_error(Philiprehberger::ConfigKit::MissingKeyError)
    end

    it 'includes key name in error message' do
      expect do
        described_class.define(env: {}) do
          required :api_key, type: :string
        end
      end.to raise_error(/api_key/)
    end

    it 'includes sources checked in error message' do
      expect do
        described_class.define(yaml: '/nonexistent.yml', env: {}) do
          required :api_key, type: :string
        end
      end.to raise_error(/env.*yaml.*default/)
    end

    it 'does not raise when required key has ENV value' do
      env = { 'API_KEY' => 'secret123' }

      config = described_class.define(env: env) do
        required :api_key, type: :string, env: 'API_KEY'
      end

      expect(config[:api_key]).to eq('secret123')
    end

    it 'does not raise when required key has YAML value' do
      yaml_file = Tempfile.new(['config', '.yml'])
      yaml_file.write(YAML.dump('api_key' => 'yaml-secret'))
      yaml_file.close

      config = described_class.define(yaml: yaml_file.path, env: {}) do
        required :api_key, type: :string
      end

      expect(config[:api_key]).to eq('yaml-secret')
    ensure
      yaml_file&.unlink
    end

    it 'casts required values to the specified type' do
      env = { 'PORT' => '8080' }

      config = described_class.define(env: env) do
        required :port, type: :integer, env: 'PORT'
      end

      expect(config[:port]).to eq(8080)
      expect(config[:port]).to be_a(Integer)
    end

    it 'raises MissingKeyError with correct error class hierarchy' do
      expect do
        described_class.define(env: {}) do
          required :missing, type: :string
        end
      end.to raise_error(Philiprehberger::ConfigKit::Error)
    end

    it 'exposes key and sources_checked on the error object' do
      error = nil
      begin
        described_class.define(env: {}) do
          required :my_key, type: :string
        end
      rescue Philiprehberger::ConfigKit::MissingKeyError => e
        error = e
      end

      expect(error.key).to eq(:my_key)
      expect(error.sources_checked).to include('env', 'default')
    end

    it 'works with required boolean type' do
      env = { 'DEBUG' => 'true' }

      config = described_class.define(env: env) do
        required :debug, type: :boolean, env: 'DEBUG'
      end

      expect(config[:debug]).to eq(true)
    end

    it 'works with required float type' do
      env = { 'RATE' => '0.75' }

      config = described_class.define(env: env) do
        required :rate, type: :float, env: 'RATE'
      end

      expect(config[:rate]).to eq(0.75)
    end
  end

  describe 'auto-generated ENV key' do
    it 'generates ENV key from symbol name automatically' do
      env = { 'APP_NAME' => 'auto-env' }

      config = described_class.define(env: env) do
        string :app_name
      end

      expect(config[:app_name]).to eq('auto-env')
    end

    it 'generates ENV key from dot-notation name' do
      env = { 'DATABASE_HOST' => 'auto-host' }

      config = described_class.define(env: env) do
        string 'database.host'
      end

      expect(config['database.host']).to eq('auto-host')
    end
  end
end

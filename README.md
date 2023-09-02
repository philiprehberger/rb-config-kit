# philiprehberger-config_kit

[![Tests](https://github.com/philiprehberger/rb-config-kit/actions/workflows/ci.yml/badge.svg)](https://github.com/philiprehberger/rb-config-kit/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/philiprehberger-config_kit.svg)](https://rubygems.org/gems/philiprehberger-config_kit)
[![Last updated](https://img.shields.io/github/last-commit/philiprehberger/rb-config-kit)](https://github.com/philiprehberger/rb-config-kit/commits/main)

Layered configuration with YAML, ENV, and defaults

## Requirements

- Ruby >= 3.1

## Installation

Add to your Gemfile:

```ruby
gem "philiprehberger-config_kit"
```

Or install directly:

```bash
gem install philiprehberger-config_kit
```

## Usage

```ruby
require "philiprehberger/config_kit"

config = Philiprehberger::ConfigKit.define do
  string :app_name, default: "my-app"
  integer :port, default: 3000
  boolean :debug, default: false
end

config[:app_name] # => "my-app"
config[:port]     # => 3000
config[:debug]    # => false
```

### With YAML file

```yaml
# config.yml
app_name: "production-app"
port: 8080
```

```ruby
config = Philiprehberger::ConfigKit.define(yaml: "config.yml") do
  string :app_name, default: "my-app"
  integer :port, default: 3000
  boolean :debug, default: false
end

config[:app_name] # => "production-app" (from YAML)
config[:port]     # => 8080             (from YAML)
config[:debug]    # => false            (from default)
```

### With ENV overrides

```ruby
config = Philiprehberger::ConfigKit.define(yaml: "config.yml") do
  string  :app_name, default: "my-app", env: "APP_NAME"
  integer :port,     default: 3000,     env: "PORT"
  boolean :debug,    default: false,    env: "DEBUG"
end

# ENV["PORT"] = "9090" would override both YAML and default
config[:port] # => 9090
```

### Nested configuration

Dot-notation keys map to nested YAML structures and uppercase ENV variables with underscores:

```ruby
config = Philiprehberger::ConfigKit.define(yaml: "config.yml") do
  string  "database.host", default: "localhost"
  integer "database.port", default: 5432
end

# Reads from YAML: database: { host: "db.example.com" }
# Or from ENV: DATABASE_HOST=db.example.com
config["database.host"] # => "db.example.com"
config.to_h             # => { "database" => { "host" => "...", "port" => 5432 } }
```

### Array and hash types

```ruby
config = Philiprehberger::ConfigKit.define do
  array :tags, of: :string   # ENV: splits by comma — "ruby,web,api"
  array :ports, of: :integer  # ENV: "3000,4000,5000" => [3000, 4000, 5000]
  hash_type :redis             # ENV: collects REDIS_HOST, REDIS_PORT into hash
end

config[:tags]  # => ["ruby", "web", "api"]
config[:ports] # => [3000, 4000, 5000]
config[:redis] # => { "host" => "localhost", "port" => "6379" }
```

### Required keys

```ruby
config = Philiprehberger::ConfigKit.define do
  required :api_key, type: :string, env: "API_KEY"
  required :port, type: :integer, env: "PORT"
end
# Raises ConfigKit::MissingKeyError if API_KEY or PORT is not set
```

### Resolution order

Values are resolved in this order (highest priority first):

1. **ENV variables** (auto-generated or explicit `env:` key)
2. **YAML file** (if `yaml:` path is provided and the key exists)
3. **Defaults** (from the schema definition)

## API

| Method | Description |
|--------|-------------|
| `Philiprehberger::ConfigKit.define(yaml:, env:, &block)` | Create a new config store |
| `config.get(key)` / `config[key]` | Get a config value |
| `config.to_h` | Export all values as a nested hash |
| `config.keys` | List all defined keys |
| `config.key?(key)` | Check if a key is defined |

### Schema DSL

| Method | Type | Cast behavior |
|--------|------|---------------|
| `string(name, default:, env:)` | `:string` | `.to_s` |
| `integer(name, default:, env:)` | `:integer` | `Integer(value)` |
| `float(name, default:, env:)` | `:float` | `Float(value)` |
| `boolean(name, default:, env:)` | `:boolean` | `true`/`"true"`/`"1"`/`"yes"` are truthy |
| `array(name, of:, default:, env:)` | `:array` | Splits ENV by comma, coerces each element |
| `hash_type(name, default:, env:)` | `:hash` | Collects `KEY_*` ENV vars into a hash |
| `required(name, type:, env:)` | varies | Raises `MissingKeyError` if no value found |

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## Support

If you find this project useful:

⭐ [Star the repo](https://github.com/philiprehberger/rb-config-kit)

🐛 [Report issues](https://github.com/philiprehberger/rb-config-kit/issues?q=is%3Aissue+is%3Aopen+label%3Abug)

💡 [Suggest features](https://github.com/philiprehberger/rb-config-kit/issues?q=is%3Aissue+is%3Aopen+label%3Aenhancement)

❤️ [Sponsor development](https://github.com/sponsors/philiprehberger)

🌐 [All Open Source Projects](https://philiprehberger.com/open-source-packages)

💻 [GitHub Profile](https://github.com/philiprehberger)

🔗 [LinkedIn Profile](https://www.linkedin.com/in/philiprehberger)

## License

[MIT](LICENSE)

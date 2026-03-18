# philiprehberger-config_kit

[![Gem Version](https://badge.fury.io/rb/philiprehberger-config_kit.svg)](https://rubygems.org/gems/philiprehberger-config_kit)
[![CI](https://github.com/philiprehberger/rb-config-kit/actions/workflows/ci.yml/badge.svg)](https://github.com/philiprehberger/rb-config-kit/actions/workflows/ci.yml)
[![License](https://img.shields.io/github/license/philiprehberger/rb-config-kit)](LICENSE)

Layered configuration with YAML, ENV, and defaults.

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

### Basic (defaults only)

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

### Resolution order

Values are resolved in this order (highest priority first):

1. **ENV variables** (if `env:` key is set and the variable exists)
2. **YAML file** (if `yaml:` path is provided and the key exists)
3. **Defaults** (from the schema definition)

### Export all values

```ruby
config.to_h
# => { app_name: "my-app", port: 3000, debug: false }
```

## API

| Method | Description |
|---|---|
| `Philiprehberger::ConfigKit.define(yaml:, env:, &block)` | Create a new config store |
| `config.get(key)` / `config[key]` | Get a config value |
| `config.to_h` | Export all values as a hash |
| `config.keys` | List all defined keys |
| `config.key?(key)` | Check if a key is defined |

### Schema DSL

| Method | Type | Cast behavior |
|---|---|---|
| `string(name, default:, env:)` | `:string` | `.to_s` |
| `integer(name, default:, env:)` | `:integer` | `Integer(value)` |
| `float(name, default:, env:)` | `:float` | `Float(value)` |
| `boolean(name, default:, env:)` | `:boolean` | `true`/`"true"`/`"1"`/`"yes"` are truthy |


## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT

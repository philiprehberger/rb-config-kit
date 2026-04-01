# frozen_string_literal: true

require_relative 'lib/philiprehberger/config_kit/version'

Gem::Specification.new do |spec|
  spec.name = 'philiprehberger-config_kit'
  spec.version = Philiprehberger::ConfigKit::VERSION
  spec.authors = ['Philip Rehberger']
  spec.email = ['me@philiprehberger.com']

  spec.summary = 'Layered configuration with YAML, ENV, and defaults'
  spec.description = 'A zero-dependency Ruby gem for layered configuration resolution. ' \
                     'Define typed config keys with defaults, load from YAML files, ' \
                     'and override with environment variables.'
  spec.homepage      = 'https://philiprehberger.com/open-source-packages/ruby/philiprehberger-config_kit'
  spec.license = 'MIT'

  spec.required_ruby_version = '>= 3.1.0'

  spec.metadata['homepage_uri']    = spec.homepage
  spec.metadata['source_code_uri']       = 'https://github.com/philiprehberger/rb-config-kit'
  spec.metadata['changelog_uri']         = 'https://github.com/philiprehberger/rb-config-kit/blob/main/CHANGELOG.md'
  spec.metadata['bug_tracker_uri']       = 'https://github.com/philiprehberger/rb-config-kit/issues'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir['lib/**/*.rb', 'LICENSE', 'README.md', 'CHANGELOG.md']
  spec.require_paths = ['lib']
end

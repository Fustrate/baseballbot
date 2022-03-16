# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'redd/version'

Gem::Specification.new do |spec|
  spec.name = 'redd'
  spec.version = Redd::VERSION
  spec.authors = ['Avinash Dwarapu']
  spec.email = ['avinash@dwarapu.me']

  spec.summary = 'A batteries-included API wrapper for reddit.'
  spec.homepage = 'https://github.com/avinashbot/redd'
  spec.license = 'MIT'

  spec.files = `git ls-files -z`.split("\x0").reject { _1.match(%r{^(spec)/}) }
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{^exe/}) { File.basename(_1) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '~> 3.1'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.add_dependency 'http', '~> 5.0'

  spec.add_development_dependency 'bundler', '~> 2.3'
  spec.add_development_dependency 'pry', '~> 0.10'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rubocop', '~> 1.25'
  spec.add_development_dependency 'rubocop-performance', '~> 1.13'
  spec.add_development_dependency 'rubocop-rspec', '~> 2.9'

  spec.add_development_dependency 'rspec', '~> 3.5'
  spec.add_development_dependency 'simplecov', '~> 0.13'
  spec.add_development_dependency 'vcr', '~> 6.0'
  spec.add_development_dependency 'webmock', '~> 3.14'
end

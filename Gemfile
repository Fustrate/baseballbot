# frozen_string_literal: true

source 'https://rubygems.org'

ruby '3.1.2'

# Error Monitoring
gem 'honeybadger', '~> 4.12'

# MLB Stats API
gem 'mlb_stats_api', '~> 0.3', github: 'Fustrate/mlb_stats_api'

# Postgres Database
gem 'pg', '~> 1.4'

# Reddit Interaction - this needs to be replaced
gem 'redd', '>= 0.9.0.pre.3', github: 'Fustrate/redd'

# Caching
gem 'redis', '~> 4.7'

# Cron jobs
gem 'whenever', '~> 1.0'

# Time zones
gem 'tzinfo', '~> 2.0'

# Fancy command line colors
gem 'paint', '~> 2.3'

group :development do
  # Deploy with Capistrano
  gem 'capistrano', '~> 3.17', require: false
  gem 'capistrano-bundler', '~> 2.1', require: false
  gem 'capistrano-rbenv', '~> 2.2', require: false

  # Linters
  gem 'rubocop', '~> 1.32'
  gem 'rubocop-performance', '~> 1.14', require: false
  gem 'rubocop-rspec', '~> 2.12', require: false
end

group :test do
  gem 'rspec', '~> 3.11'
  gem 'webmock', '~> 3.14'
end

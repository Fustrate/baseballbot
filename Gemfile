# frozen_string_literal: true

source 'https://rubygems.org'

ruby '3.1.0'

# Date Parsing
gem 'chronic'

# Error Monitoring
gem 'honeybadger', '~> 4.0'

# MLB Stats API
gem 'mlb_stats_api', github: 'Fustrate/mlb_stats_api'

# Postgres Database
gem 'pg'

# Reddit Interaction
gem 'redd', path: 'vendor/redd'

# Caching
gem 'redis'

# Cron jobs
gem 'whenever'

# Time zones
gem 'tzinfo'

# Fancy command line colors
gem 'paint'

group :development do
  # Deploy with Capistrano
  gem 'capistrano', '~> 3.15', require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano-rbenv', '~> 2.1', require: false

  # Linters
  gem 'rubocop'
  gem 'rubocop-performance', require: false
  gem 'rubocop-rspec', require: false
end

group :test do
  gem 'rspec', '~> 3.8'
  gem 'webmock', '~> 3.4'
end

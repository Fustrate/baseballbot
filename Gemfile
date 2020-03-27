# frozen_string_literal: true

source 'https://rubygems.org'

ruby '2.6.5'

# Date Parsing
gem 'chronic'

# Error Monitoring
gem 'honeybadger', '~> 4.0'

# MLB Stats API
gem 'mlb_stats_api', github: 'Fustrate/mlb_stats_api'

# Postgres Database
gem 'pg'

# Reddit Interaction
gem 'redd' # , github: 'avinashbot/redd'

# Caching
gem 'redis'

# Cron jobs
gem 'whenever'

group :development do
  # Deploy with Capistrano
  gem 'capistrano', '~> 3.11', require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano-rbenv', '~> 2.1', require: false

  # Linters
  gem 'rubocop'
  gem 'rubocop-performance', require: false
end

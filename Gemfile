# frozen_string_literal: true

source 'https://rubygems.org'

ruby file: "#{File.expand_path(__dir__)}/.ruby-version"

# App Monitoring [https://github.com/honeybadger-io/honeybadger-ruby]
gem 'honeybadger', '~> 5.0'

# Fetch data from the MLB Stats API [https://github.com/Fustrate/mlb_stats_api]
gem 'mlb_stats_api', '~> 0.3', github: 'Fustrate/mlb_stats_api'

# Postgres database [https://github.com/ged/ruby-pg]
gem 'pg', '~> 1.4'

# Reddit interaction [https://github.com/Fustrate/redd]
gem 'redd', '>= 0.9.0.pre.3', github: 'Fustrate/redd'

# A more slim redis client [https://github.com/redis/redis-rb]
gem 'redis', '~> 5.0'

# Use an ORM instead of interacting with pg directly [https://github.com/jeremyevans/sequel]
gem 'sequel', '~> 5.71'

# Cron jobs
gem 'whenever', '~> 1.0'

# Time zone information
gem 'tzinfo', '~> 2.0'

# Fancy command line colors
gem 'paint', '~> 2.3'

# File autoloading
gem 'zeitwerk', '~> 2.6'

# Formatting that users can mess up without destroying the bot itself
gem 'mustache'

# Command line options for scripts
gem 'thor'

# Generate CSV files for flair lists
gem 'csv', '~> 3.2'

group :development do
  # Deploy with Capistrano [https://github.com/capistrano/capistrano]
  gem 'capistrano', '~> 3.17', require: false

  # Capistrano Bundler integration [https://github.com/capistrano/bundler]
  gem 'capistrano-bundler', '~> 2.1', require: false

  # Capistrano rbenv integration [https://github.com/capistrano/rbenv]
  gem 'capistrano-rbenv', '~> 2.2', require: false

  # Ruby code linting [https://github.com/rubocop/rubocop]
  gem 'rubocop', '~> 1.42', require: false

  # Rubocop - performance cops [https://github.com/rubocop/rubocop-performance]
  gem 'rubocop-performance', '~> 1.14', require: false

  # Rubocop - rspec cops [https://github.com/rubocop/rubocop-rspec]
  gem 'rubocop-rspec', '~> 2.12', require: false
end

group :test do
  # Mock the redis server/client [https://github.com/sds/mock_redis]
  gem 'mock_redis', '~> 0.32'

  # Automated testing framework
  gem 'rspec', '~> 3.11'

  # Mock HTTP requests instead of hitting external servers
  gem 'webmock', '~> 3.14'
end

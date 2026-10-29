# frozen_string_literal: true

set :output, '/home/baseballbot/apps/baseballbot/shared/log/whenever.log'

# We have to run in the root directory or the Honeybadger config file won't be picked up
ROOT_DIR = '/home/baseballbot/apps/baseballbot/current'

def step_minutes_by(step, except: [], &)
  every("#{(0.step(59, step).to_a - Array(except)).join(',')} * * * *", &)
end

def process_kwarg(key, value)
  return "--#{key}" if value.is_a?(TrueClass)

  "--#{key}=#{value.is_a?(Array) ? value.join(',') : value}"
end

def cli(*command, **kwargs)
  cli_args = [*command, *kwargs.map { |k, v| process_kwarg(k, v) }].join(' ')

  command "cd #{ROOT_DIR} && bundle exec ruby scripts/cli.rb #{cli_args}"
end

every 1.hour do
  cli :sidebars, :update
  cli :game_threads, :off_day
end

every 5.minutes do
  cli :around_the_horn
end

# So we don't run twice on the hour
step_minutes_by(5, except: 0) do
  cli :sidebars, :update, subreddits: :baseball
end

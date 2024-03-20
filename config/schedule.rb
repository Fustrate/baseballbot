# frozen_string_literal: true

set :output, '/home/baseballbot/apps/baseballbot/shared/log/whenever.log'

# We have to run in the root directory or the Honeybadger config file won't be picked up
ROOT_DIR = '/home/baseballbot/apps/baseballbot/current'

def step_minutes_by(step, except: [], &block)
  every "#{(0.step(59, step).to_a - Array(except)).join(',')} * * * *", &block
end

def process_kwarg(key, value)
  return "--#{key}" if value.is_a?(TrueClass)

  "--#{key}=#{value.is_a?(Array) ? value.join(',') : value}"
end

def cli(*command, **kwargs)
  cli_args = [*command, *kwargs.map { |k, v| process_kwarg(k, v) }].join(' ')

  command "cd #{ROOT_DIR} && bundle exec ruby scripts/cli.rb #{cli_args}"
end

every :minute do
  cli :no_hitters
end

every 1.hour do
  cli :sidebars, :update
  cli :game_threads, :off_day
end

every 15.minutes do
  cli :check_messages
  cli :game_threads, :pregame
end

every 5.minutes do
  cli :game_threads, :post
  cli :around_the_horn
end

# So we don't run twice on the hour
step_minutes_by(5, except: 0) do
  cli :sidebars, :update, subreddits: :baseball
end

step_minutes_by(2, except: [0, 30]) do
  cli :game_threads, :update, live: true
end

step_minutes_by(30) do
  cli :game_threads, :update
end

every :day do
  cli :game_threads, :load
  cli :game_threads, :load_r_baseball
  # cli :game_threads, :load_r_albeast
  cli :sync_moderators
end

every :saturday do
  cli :game_threads, :load_sunday
end

every '30 4 * 9,10,11 *' do
  cli :game_threads, :load_postseason
end

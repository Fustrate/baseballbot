# frozen_string_literal: true

set :output, '/home/baseballbot/apps/baseballbot/shared/log/whenever.log'

SCRIPTS_DIR = '/home/baseballbot/apps/baseballbot/current/scripts'
BUNDLE_EXEC = 'bundle exec'

def step_minutes_by(step, except: [], &block)
  every "#{(0.step(59, step).to_a - Array(except)).join(',')} * * * *", &block
end

def bundle_exec_ruby(name, *args) = command "cd #{SCRIPTS_DIR} && #{BUNDLE_EXEC} ruby #{name}.rb #{args.join(' ')}"

def process_kwarg(key, value)
  return "--#{key}" if value.is_a?(TrueClass)

  "--#{key}=#{value.is_a?(Array) ? value.join(',') : value}"
end

def cli(*command, **kwargs)
  cli_args = [*command, *kwargs.map { |k, v| process_kwarg(k, v) }].join(' ')

  command "cd #{SCRIPTS_DIR} && #{BUNDLE_EXEC} ruby cli.rb #{cli_args}"
end

every :minute do
  bundle_exec_ruby :no_hitter_bot
  bundle_exec_ruby :mod_queue_slack
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
  bundle_exec_ruby :around_the_horn, :update
end

# So we don't run twice on the hour
step_minutes_by(5, except: 0) do
  cli :sidebars, :update, subreddits: :baseball
end

step_minutes_by(2, except: [0, 30]) do
  cli :game_threads, :update
end

step_minutes_by(30) do
  cli :game_threads, :update, posted: true
end

every :day do
  cli :game_threads, :load
end

every :saturday do
  cli :game_threads, :load_sunday
end

every 1.day, at: '4:30 am' do
  bundle_exec_ruby :around_the_horn, :post
  cli :sync_moderators
end

# every '30 4 * 9,10,11 *' do
#   cli :game_threads, :load_postseason
# end

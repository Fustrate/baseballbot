# frozen_string_literal: true

set :output, '/home/baseballbot/apps/baseballbot/shared/log/whenever.log'

SCRIPTS_DIR = '/home/baseballbot/apps/baseballbot/current/scripts'
BUNDLE_EXEC = 'bundle exec'

def step_minutes_by(step, except: [], &block)
  every "#{(0.step(59, step).to_a - Array(except)).join(',')} * * * *", &block
end

def bundle_exec_ruby(name, *args) = command "cd #{SCRIPTS_DIR} && #{BUNDLE_EXEC} ruby #{name}.rb #{args.join(' ')}"

def cli(action, *args, **kwargs)
  script_arguments = [
    *args.map { "--#{_1}" },
    *kwargs.map { |k, v| "--#{k}=#{v.is_a?(Array) ? v.join(',') : v}" }
  ]

  command "cd #{SCRIPTS_DIR} && #{BUNDLE_EXEC} ruby cli.rb #{action} #{script_arguments.join(' ')}"
end

every :minute do
  bundle_exec_ruby :no_hitter_bot
  bundle_exec_ruby :mod_queue_slack
end

every 1.hour do
  bundle_exec_ruby :sidebars, :update
  bundle_exec_ruby :game_threads, :off_day
end

every 15.minutes do
  cli :check_messages
  bundle_exec_ruby :game_threads, :pregame
end

every 5.minutes do
  bundle_exec_ruby :game_threads, :post
  bundle_exec_ruby :around_the_horn, :update
end

# So we don't run twice on the hour
step_minutes_by(5, except: 0) do
  bundle_exec_ruby :sidebars, :update, :baseball
end

step_minutes_by(2, except: [0, 30]) do
  bundle_exec_ruby :game_threads, :update
end

step_minutes_by(30) do
  bundle_exec_ruby :game_threads, :update, :posted
end

every :day do
  bundle_exec_ruby :load_game_threads
end

every :saturday do
  bundle_exec_ruby :load_sunday_game_threads
end

every 1.day, at: '4:30 am' do
  bundle_exec_ruby :around_the_horn, :post
  cli :sync_moderators
end

# every '30 4 * 9,10,11 *' do
#   cli :load_postseason_game_threads
# end

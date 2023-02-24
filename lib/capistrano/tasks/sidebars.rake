# frozen_string_literal: true

namespace :bot do
  desc 'Subreddit sidebars'
  task :sidebars, %i[action subreddits] do |_, args|
    raise 'Please provide an action to perform.' unless args[:action]

    subreddits = args[:subreddits]&.split('+') || []

    on roles(:web) do
      within "#{release_path}/scripts" do
        execute(:bundle, :exec, :ruby, 'sidebars.rb', args[:action], *subreddits)
      end
    end
  end
end

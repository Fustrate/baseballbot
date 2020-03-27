# frozen_string_literal: true

namespace :bot do
  desc 'Post/update game threads'
  task :game_threads, %i[action subreddits] do |_, args|
    raise 'Please provide an action to perform.' unless args[:action]

    subreddits = args[:subreddits]&.split('+') || []

    on roles(:web) do
      within "#{release_path}/lib" do
        execute(
          :bundle, :exec, :ruby,
          'game_threads.rb',
          args[:action],
          *subreddits
        )
      end
    end
  end
end

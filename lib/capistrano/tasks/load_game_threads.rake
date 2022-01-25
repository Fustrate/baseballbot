# frozen_string_literal: true

namespace :bot do
  desc 'Load game threads'
  task :load_game_threads, %i[month teams] do |_, args|
    on roles(:web) do
      within "#{release_path}/lib" do
        execute(:bundle, :exec, :ruby, 'load_game_threads.rb', args[:month], args[:teams]&.tr('+', ','))
      end
    end
  end
end

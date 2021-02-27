# frozen_string_literal: true

namespace :bot do
  desc 'Refresh tokens'
  task :refresh_tokens, %i[names] do |_, args|
    on roles(:web) do
      within "#{release_path}/lib" do
        execute(:bundle, :exec, :ruby, 'refresh_tokens.rb', args[:names])
      end
    end
  end
end

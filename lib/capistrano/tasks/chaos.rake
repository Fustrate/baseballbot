# frozen_string_literal: true

namespace :bot do
  desc 'Chaos!'
  task :chaos, %i[teams] do |_, args|
    if args[:teams].blank?
      raise 'Please provide one or more wagons to light on fire.'
    end

    on roles(:web) do
      within "#{release_path}/lib" do
        execute(:bundle, :exec, :ruby, 'chaos.rb', args[:teams].tr('+', ','))
      end
    end
  end
end

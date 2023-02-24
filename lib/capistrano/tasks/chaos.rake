# frozen_string_literal: true

namespace :bot do
  desc 'Chaos!'
  task :chaos, %i[teams] do |_, args|
    raise 'Please provide one or more wagons to light on fire.' if args[:teams].blank?

    on roles(:web) do
      within "#{release_path}/scripts" do
        execute(:bundle, :exec, :ruby, 'chaos.rb', args[:teams].tr('+', ','))
      end
    end
  end
end

# frozen_string_literal: true

require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

Dir.glob('lib/tasks/**/*.rake').each { load it }

task default: :spec

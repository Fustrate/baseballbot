# frozen_string_literal: true

ENV['BASEBALLBOT_PG_DATABASE'] = 'baseballbot_test'

require 'webmock/rspec'
require 'mlb_stats_api'
require 'open-uri'
require 'fileutils'
require 'mock_redis'
require 'mustache'

Dir.glob(File.join(__dir__, 'support/*.rb')).each { require_relative it }

require_relative '../lib/baseballbot'

class Baseballbot
  def redis
    @redis ||= MockRedis.new
  end

  def api
    @api ||= MLBStatsAPI::Client.new logger:, cache: nil
  end

  def logger
    @logger ||= Logger.new(File::NULL)
  end
end

RSpec.configure do |config|
  config.around do |example|
    DB.transaction(rollback: :always, auto_savepoint: true) { example.run }
  end

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.filter_run :focus
  config.run_all_when_everything_filtered = true
  config.default_formatter = 'doc' if config.files_to_run.one?
  config.disable_monkey_patching!
  config.warnings = true
  # config.profile_examples = 10
  config.order = :random

  Kernel.srand config.seed

  config.include WebmockHelpers
  config.include BotHelpers

  config.before do
    allow(Time).to receive(:now).and_return(Time.parse('2022-07-04 09:28:41'))
  end
end

# We never want to actually hit the outside world. All data should be stored in the data directory, and new data can be
# grabbed manually.
WebMock.disable_net_connect!

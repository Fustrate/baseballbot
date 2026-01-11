# frozen_string_literal: true

require 'erb'
require 'logger'
require 'mlb_stats_api'
require 'open-uri'
require 'pg'
require 'redd'
require 'redis'
require 'tzinfo'

# Require honeybadger after other gems in case there are integrations it can detect.
require 'honeybadger'

loader = Zeitwerk::Loader.new
loader.push_dir(__dir__)
loader.setup

class Baseballbot
  include Database

  include Bots
  include GameThreads
  include OffDay
  include Pregames
  include Sidebars
  include Subreddits

  def initialize(**options)
    @options = options
  end

  def api
    @api ||= MLBStatsAPI::Client.new logger:, cache: redis
  end

  # Returns one of 'postseason', 'regular_season', 'offseason', 'preseason'
  def season_state
    @season_state ||= @api.leagues(sportId: 1).dig('leagues', 0, 'seasonState')
  end

  def client
    raise 'Baseballbot was not initialized with :user_agent.' unless @options[:user_agent]

    @client ||= Redd::APIClient.new redd_auth_strategy, limit_time: 5
  end

  def db
    @db ||= PG::Connection.new(
      host: ENV.fetch('BASEBALLBOT_PG_HOST', nil),
      user: ENV.fetch('BASEBALLBOT_PG_USERNAME'),
      dbname: ENV.fetch('BASEBALLBOT_PG_DATABASE'),
      password: ENV.fetch('BASEBALLBOT_PG_PASSWORD')
    )
  end

  def logger
    @logger ||= @options[:logger] || Logger.new($stdout)
  end

  def log_action(subject_type:, subject_id:, action:, note: nil, data: {})
    sequel[:bot_actions].insert(
      subject_type:,
      subject_id:,
      action:,
      note:,
      data: Sequel.pg_jsonb(data)
    )
  end

  def redis
    @redis ||= Redis.new
  end

  def session
    raise 'Baseballbot was not initialized with :user_agent.' unless @options[:user_agent]

    @session ||= Redd::Models::Session.new client
  end

  def inspect = %(#<#{self.class.name}>)

  def bots
    @bots ||= load_bots
  end

  def subreddits
    @subreddits ||= load_subreddits
  end

  protected

  def redd_auth_strategy
    Redd::AuthStrategies::Web.new(
      client_id: ENV.fetch('REDDIT_CLIENT_ID'),
      secret: ENV.fetch('REDDIT_SECRET'),
      redirect_uri: ENV.fetch('REDDIT_REDIRECT_URI'),
      user_agent: @options[:user_agent] || 'Baseballbot'
    )
  end
end

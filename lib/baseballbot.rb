# frozen_string_literal: true

require 'chronic'
require 'erb'
require 'honeybadger/ruby'
require 'logger'
require 'mlb_stats_api'
require 'open-uri'
require 'pg'
require 'redd'
require 'redis'
require 'tzinfo'

require_relative 'baseballbot/error'
require_relative 'baseballbot/subreddit'
require_relative 'baseballbot/account'
require_relative 'baseballbot/utility'

require_relative 'baseballbot/accounts'
require_relative 'baseballbot/game_threads'
require_relative 'baseballbot/off_day'
require_relative 'baseballbot/pregames'
require_relative 'baseballbot/sidebars'
require_relative 'baseballbot/subreddits'

Dir.glob(File.join(File.dirname(__FILE__), 'baseballbot/{template,posts}/*.rb')).each { require_relative _1 }

class Baseballbot
  include Accounts
  include GameThreads
  include OffDay
  include Pregames
  include Sidebars
  include Subreddits

  IGNORED_EXCEPTIONS = [::Redd::Errors::ServerError, ::OpenURI::HTTPError, ::HTTP::TimeoutError].freeze

  def initialize(**options)
    @options = options

    configure_honeybadger
  end

  def configure_honeybadger
    Honeybadger.configure do |config|
      # For some reason, this isn't getting pulled from ENV. Do some research.
      config.api_key = ENV['HONEYBADGER_API_KEY']

      config.breadcrumbs.enabled = true
      config.env = 'bot'

      config.before_notify { _1.halt! if IGNORED_EXCEPTIONS.any?(_1.exception) }
    end
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
      user: ENV['BASEBALLBOT_PG_USERNAME'],
      dbname: ENV['BASEBALLBOT_PG_DATABASE'],
      password: ENV['BASEBALLBOT_PG_PASSWORD']
    )
  end

  def logger
    @logger ||= @options[:logger] || Logger.new($stdout)
  end

  def log_action(subject_type:, subject_id:, action:, note: nil, data: {})
    db.exec_params(<<~SQL, [subject_type, subject_id, action, note, data])
      INSERT INTO bot_actions (subject_type, subject_id, action, note, data)
      VALUES ($1, $2, $3, $4, $5)
    SQL
  end

  def redis
    @redis ||= Redis.new
  end

  def session
    raise 'Baseballbot was not initialized with :user_agent.' unless @options[:user_agent]

    @session ||= Redd::Models::Session.new client
  end

  def inspect = %(#<Baseballbot>)

  def accounts
    @accounts ||= load_accounts
  end

  def subreddits
    @subreddits ||= load_subreddits
  end

  protected

  def redd_auth_strategy
    Redd::AuthStrategies::Web.new(
      client_id: ENV['REDDIT_CLIENT_ID'],
      secret: ENV['REDDIT_SECRET'],
      redirect_uri: ENV['REDDIT_REDIRECT_URI'],
      user_agent: @options[:user_agent] || 'Baseballbot'
    )
  end
end

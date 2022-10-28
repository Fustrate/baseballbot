# frozen_string_literal: true

require 'erb'
require 'honeybadger/ruby'
require 'logger'
require 'mlb_stats_api'
require 'open-uri'
require 'pg'
require 'redd'
require 'redis'
require 'tzinfo'

loader = Zeitwerk::Loader.new
loader.push_dir(__dir__)
loader.setup

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
    api_key = ENV.fetch('HONEYBADGER_API_KEY', nil)

    return unless api_key

    Honeybadger.configure do |config|
      # For some reason, this isn't getting pulled from ENV. Do some research.
      config.api_key = api_key

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
      user: ENV.fetch('BASEBALLBOT_PG_USERNAME'),
      dbname: ENV.fetch('BASEBALLBOT_PG_DATABASE'),
      password: ENV.fetch('BASEBALLBOT_PG_PASSWORD')
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
      client_id: ENV.fetch('REDDIT_CLIENT_ID'),
      secret: ENV.fetch('REDDIT_SECRET'),
      redirect_uri: ENV.fetch('REDDIT_REDIRECT_URI'),
      user_agent: @options[:user_agent] || 'Baseballbot'
    )
  end
end

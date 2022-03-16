# frozen_string_literal: true

require 'uri'

# Redd Version
require_relative 'redd/version'
# Models
Dir[File.join(__dir__, 'redd', 'models', '*.rb')].each { require _1 }
# Authentication Clients
Dir[File.join(__dir__, 'redd', 'auth_strategies', '*.rb')].each { require _1 }
# Regular Client
require_relative 'redd/api_client'

# Redd is a simple and intuitive API wrapper.
module Redd
  class << self
    AUTHORIZATION_URL = 'https://www.reddit.com/api/v1/authorize?client_id=%<client_id>s' \
                        '&redirect_uri=%<redirect_uri>s&state=%<state>s&scope=%<scope>s' \
                        '&response_type=%<response_type>s&duration=%<duration>s'

    AUTH_OPTIONS = %i[client_id secret username password redirect_uri user_agent].freeze

    API_OPTIONS = %i[user_agent limit_time max_retries auto_refresh].freeze

    # Based on the arguments you provide it, it guesses the appropriate authentication strategy.
    # You can do this manually with:
    #
    #     script   = Redd::AuthStrategies::Script.new(**arguments)
    #     web      = Redd::AuthStrategies::Web.new(**arguments)
    #     userless = Redd::AuthStrategies::Userless.new(**arguments)
    #
    # It then creates an {APIClient} with the auth strategy provided and calls authenticate on it:
    #
    #     client = Redd::APIClient.new(script); client.authenticate(code)
    #     client = Redd::APIClient.new(web); client.authenticate
    #     client = Redd::APIClient.new(userless); client.authenticate
    #
    # Finally, it creates the {Models::Session} model, which is essentially a starting point for
    # the user. But you can basically create any model with the client.
    #
    #     session = Redd::Models::Session.new(client)
    #
    #     user = Redd::Models::User.new(client, name: 'Mustermind')
    #     puts user.comment_karma
    #
    # If `auto_refresh` is `false` or if the access doesn't have an associated `expires_in`, you
    # can manually refresh the token by calling:
    #
    #     session.client.refresh
    #
    # Also, you can swap out the client's access any time.
    #
    #     new_access = { access_token: '', refresh_token: '', expires_in: 1234 }
    #
    #     session.client.access = Redd::Models::Access.new(script, new_access)
    #     session.client.access = Redd::Models::Access.new(web, new_access)
    #     session.client.access = Redd::Models::Access.new(userless, new_access)
    #
    # @see https://www.reddit.com/prefs/apps
    # @param opts [Hash] the options to create the object with
    # @option opts [String] :user_agent your app's *unique* and *descriptive* user agent
    # @option opts [String] :client_id the client id of your app
    # @option opts [String] :secret the app secret (for confidential types, i.e. *not* *installed*)
    # @option opts [String] :username the username of your bot (only for *script*)
    # @option opts [String] :password the plaintext password of your bot (only for *script*)
    # @option opts [String] :redirect_uri the provided redirect URI (only for *web* and *installed*)
    # @option opts [String] :code the code given by reddit (required for *web* and *installed*)
    # @return [Models::Session] a fresh {Models::Session} for you to make requests with
    def it(opts = {})
      api_client = script(opts) || web(opts) || userless(opts)

      raise "couldn't guess app type" unless api_client

      Models::Session.new(api_client)
    end

    # Create a url to send to users for authorization.
    # @param response_type ['code', 'token'] the type of response from reddit
    # @param state [String] a randomly generated token to avoid CSRF attacks.
    # @param client_id [String] the client id of the app
    # @param redirect_uri [String] the URI for reddit to redirect to after authorization
    # @param scope [Array<String>] an array of scopes to request
    # @param duration ['temporary', 'permanent'] the duration to request the code for (only applies
    #   when response_type is 'code')
    # @return [String] the generated url
    def url(**options)
      validate_url_options!(options)

      format(
        AUTHORIZATION_URL,
        client_id: options[:client_id],
        redirect_uri: URI.encode_www_form(options[:redirect_uri]),
        state: options[:state],
        scope: (options[:scope] || %w[identity]).join(','),
        response_type: options[:response_type] || 'code',
        duration: options[:duration] || 'temporary'
      )
    end

    private

    def validate_url_options!(options)
      raise 'client_id required' unless options[:client_id]
      raise 'redirect_uri required' unless options[:redirect_uri]
    end

    def filter_auth(opts) = opts.select { AUTH_OPTIONS.include?(_1) }

    def filter_api(opts) = opts.select { API_OPTIONS.include?(_1) }

    def script(opts = {})
      return unless %i[client_id secret username password].all? { opts.include?(_1) }

      auth = AuthStrategies::Script.new(filter_auth(opts))
      api = APIClient.new(auth, **filter_api(opts))
      api.tap(&:authenticate)
    end

    def web(opts = {})
      return unless %i[client_id redirect_uri code].all? { opts.include?(_1) }

      auth = AuthStrategies::Web.new(**filter_auth(opts))
      api = APIClient.new(auth, **filter_api(opts))
      api.tap { _1.authenticate(opts[:code]) }
    end

    def userless(opts = {})
      return unless %i[client_id secret].all? { opts.include?(_1) }

      auth = AuthStrategies::Userless.new(filter_auth(opts))
      api = APIClient.new(auth, **filter_api(opts))
      api.tap(&:authenticate)
    end
  end
end

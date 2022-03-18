# frozen_string_literal: true

require_relative '../client'

module Redd
  module AuthStrategies
    # The API client for authentication to reddit.
    class AuthStrategy < Client
      # The API to make authentication requests to.
      AUTH_ENDPOINT = 'https://www.reddit.com'

      # @param client_id [String] the client id of the reddit app
      # @param secret [String] the app's secret string
      # @param endpoint [String] the url to contact for authentication requests
      # @param user_agent [String] the user agent to send with requests
      def initialize(client_id:, secret:, endpoint: AUTH_ENDPOINT, user_agent: USER_AGENT)
        super(endpoint:, user_agent:)

        @client_id = client_id
        @secret = secret
      end

      # @abstract Perform authentication and return the resulting access object
      # @return [Access] the access token object
      def authenticate(*) = raise 'abstract method: this strategy cannot authenticate with reddit'

      # @return [Boolean] whether the access object can be refreshed
      def refreshable?(_access) = false

      # @abstract Refresh the authentication and return the refreshed access
      # @param _access [Access, String] the access to refresh
      # @return [Access] the new access
      def refresh(_access) = raise 'abstract method: this strategy cannot refresh access'

      # Revoke the access token, making it invalid for future requests.
      # @param access [Access, String] the access to revoke
      def revoke(access) = post('/api/v1/revoke_token', token: access_token(access))

      private

      def connection
        @connection ||= super.basic_auth(user: @client_id, pass: @secret)
      end

      def access_token(access)
        return access if access.is_a?(String)

        access.respond_to?(:refresh_token) ? access.refresh_token : access.access_token
      end

      def request_access(grant_type, **options)
        response = post('/api/v1/access_token', { grant_type: }.merge(options))

        raise Errors::AuthenticationError, response if response.body.key?(:error)

        Models::Access.new(response.body)
      end
    end
  end
end

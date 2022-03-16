# frozen_string_literal: true

require_relative 'auth_strategy'

module Redd
  module AuthStrategies
    # A typical code-based authentication, for 'web' and 'installed' types.
    class Web < AuthStrategy
      def initialize(client_id:, redirect_uri:, secret: '', **kwargs)
        super(client_id:, secret:, **kwargs)

        @redirect_uri = redirect_uri
      end

      # Authenticate with a code using the "web" flow.
      # @param code [String] the code returned by reddit
      # @return [Access]
      def authenticate(code)
        request_access('authorization_code', code:, redirect_uri: @redirect_uri)
      end

      # Refresh the authentication and return a new refreshed access
      # @return [Access] the new access
      def refresh(access)
        token = access.is_a?(String) ? refresh_token : access.refresh_token

        response = post('/api/v1/access_token', grant_type: 'refresh_token', refresh_token: token)

        # When refreshed, the response doesn't include an access token, so we have to add it.
        Models::Access.new(self, response.body.merge(refresh_token: token))
      end
    end
  end
end

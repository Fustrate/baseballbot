# frozen_string_literal: true

module Redd
  # Bump the timeouts up from 5 seconds
  class Client
    private

    def connection
      @connection ||= HTTP.persistent(@endpoint)
        .headers('User-Agent' => @user_agent)
        .timeout(write: 20, connect: 20, read: 20)
    end
  end

  module Models
    class Subreddit < Model
      # Fix for Ruby 3
      def modify_settings(...)
        full_params = settings.merge(...).merge(sr: read_attribute(:name))

        SETTINGS_MAP.each { |src, dest| full_params[dest] = full_params.delete(src) }

        client.post('/api/site_admin', full_params)
      end
    end
  end
end

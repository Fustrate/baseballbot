# frozen_string_literal: true

class Baseballbot
  module Templates
    module Components
      class PickTheStick
        BASE_URL = 'https://www.pick-the-stick.com/api/standings?api_token=%<token>s&team=%<team_code>s'

        include MarkdownHelpers

        def initialize(subreddit)
          @subreddit = subreddit
        end

        def current_standings
          return '[](/pickthestick "Team not configured")' unless @subreddit.team&.code

          @data = pick_the_stick_data

          ''
        end

        protected

        def pick_the_stick_data
          api_token = ENV.fetch('BASEBALLBOT_PTS_TOKEN', nil)

          raise 'API token is required' unless api_token && !api_token.empty?

          raise 'Team code is required' if team_code.nil? || team_code.empty?

          JSON.parse(URI.parse(format(BASE_URL, api_token:, team_code:)).open.read)
        end
      end
    end
  end
end

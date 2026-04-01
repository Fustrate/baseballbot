# frozen_string_literal: true

class Baseballbot
  module Templates
    module Components
      class PickTheStick
        BASE_URL = 'https://www.pick-the-stick.com/api/standings?api_token=%<token>s&team=%<team_code>s&sort=desc'

        include MarkdownHelpers

        TABLE_HEADERS = [
          ['Rank', :center],
          ['User', :center],
          ['Points', :center],
          ['Total Picks', :center],
          ['Position Change', :center]
        ]

        def initialize(subreddit)
          @subreddit = subreddit
        end

        def to_s
          return '[](/pickthestick "Team not configured")' unless @subreddit.team&.code

          table(headers: TABLE_HEADERS, rows:)
        end

        protected

        def rows
          pick_the_stick_data.first(10).map do |entry|
            [
              entry['ranking'],
              entry['username'],
              entry['points'],
              entry['total_picks'],
              entry['position_change']
            ]
          end
        end

        def pick_the_stick_data
          api_token = ENV.fetch('BASEBALLBOT_PTS_TOKEN', nil)
          team_code = @subreddit.team.code

          raise 'API token is required' unless api_token && !api_token.empty?

          raise 'Team code is required' if team_code.nil? || team_code.empty?

          JSON.parse(URI.parse(format(BASE_URL, api_token:, team_code:)).open.read)
        end
      end
    end
  end
end

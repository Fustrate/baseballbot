# frozen_string_literal: true

class Baseballbot
  module Templates
    module Sidebars
      module Components
        def postseason_series_section = Postseason.new(@subreddit)

        def hitter_stats(...) = Leaders.new(@subreddit).hitter_stats(...)

        def pitcher_stats(...) = Leaders.new(@subreddit).pitcher_stats(...)

        def hitter_stats_table(...) = Leaders.new(@subreddit).hitter_stats_table(...)

        def pitcher_stats_table(...) = Leaders.new(@subreddit).pitcher_stats_table(...)

        def calendar = Calendar.new(@subreddit)

        # Allows /r/baseball to show both spring leagues
        def cactus_league_standings = SpringStandings.new(@subreddit, league: :cactus)

        # Allows /r/baseball to show both spring leagues
        def grapefruit_league_standings = SpringStandings.new(@subreddit, league: :grapefruit)

        def updated_with_link
          "[Updated](https://baseballbot.io) #{@subreddit.now.strftime('%-m/%-d at %-I:%M %p %Z')}".strip
        end

        def team_stats
          @team_stats ||= Standings.new(@subreddit).team_stats
        end
      end
    end
  end
end

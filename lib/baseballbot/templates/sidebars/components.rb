# frozen_string_literal: true

Dir.glob(File.join(__dir__, 'components/*.rb')).each { require _1 }

class Baseballbot
  module Templates
    module Sidebars
      module Components
        def postseason_series_section = Sidebars::Postseason.new(@subreddit).to_s

        def todays_games(date = nil) = Sidebars::TodaysGames.new(@subreddit, date)

        def hitter_stats(...) = Sidebars::Leaders.new(@subreddit).hitter_stats(...)

        def pitcher_stats(...) = Sidebars::Leaders.new(@subreddit).pitcher_stats(...)

        def hitter_stats_table(...) = Sidebars::Leaders.new(@subreddit).hitter_stats_table(...)

        def pitcher_stats_table(...) = Sidebars::Leaders.new(@subreddit).pitcher_stats_table(...)

        def calendar = Sidebars::Calendar.new(@subreddit).to_s

        def division_standings = Sidebars::DivisionStandings.new(@subreddit)

        def league_standings = Sidebars::LeagueStandings.new(@subreddit).to_s

        def updated_with_link
          "[Updated](https://baseballbot.io) #{@subreddit.now.strftime('%-m/%-d at %-I:%M %p %Z')}"
        end
      end
    end
  end
end

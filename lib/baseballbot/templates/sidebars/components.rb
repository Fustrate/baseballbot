# frozen_string_literal: true

class Baseballbot
  module Templates
    module Sidebars
      module Components
        def postseason_series_section = Postseason.new(@subreddit)

        def todays_games(date = nil) = TodaysGames.new(@subreddit, date)

        def hitter_stats(...) = Leaders.new(@subreddit).hitter_stats(...)

        def pitcher_stats(...) = Leaders.new(@subreddit).pitcher_stats(...)

        def hitter_stats_table(...) = Leaders.new(@subreddit).hitter_stats_table(...)

        def pitcher_stats_table(...) = Leaders.new(@subreddit).pitcher_stats_table(...)

        def calendar = Calendar.new(@subreddit)

        def month_games = schedule.month_games

        def previous_games(...) = schedule.previous_games(...)

        def upcoming_games(...) = schedule.upcoming_games(...)

        def next_game_str(...) = schedule.next_game_str(...)

        def last_game_str(...) = schedule.last_game_str(...)

        def division_standings = DivisionStandings.new(@subreddit).to_a

        def league_standings = LeagueStandings.new(@subreddit)

        def updated_with_link
          "[Updated](https://baseballbot.io) #{@subreddit.now.strftime('%-m/%-d at %-I:%M %p %Z')}"
        end

        protected

        def schedule
          @schedule ||= Schedule.new(@subreddit)
        end
      end
    end
  end
end

# frozen_string_literal: true

class Baseballbot
  module Templates
    module Components
      def month_games = schedule.month_games

      def previous_games(...) = schedule.previous_games(...)

      def upcoming_games(...) = schedule.upcoming_games(...)

      def next_game_str(...) = schedule.next_game_str(...)

      def last_game_str(...) = schedule.last_game_str(...)

      # Templates iterate over this as a Mustache section, so it can't be wrapped in markers.
      def division_standings = DivisionStandings.new(@subreddit)

      def pick_the_stick = PickTheStick.new(@subreddit)

      def team_stats
        @team_stats ||= Standings.new(@subreddit).team_stats
      end

      protected

      def schedule
        @schedule ||= Schedule.new(@subreddit)
      end
    end
  end
end

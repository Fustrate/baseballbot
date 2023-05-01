# frozen_string_literal: true

class Baseballbot
  module Templates
    module Components
      def todays_games(date = nil) = TodaysGames.new(@subreddit, date:, links: :code)

      def month_games = schedule.month_games

      def previous_games(...) = schedule.previous_games(...)

      def upcoming_games(...) = schedule.upcoming_games(...)

      def next_game_str(...) = schedule.next_game_str(...)

      def last_game_str(...) = schedule.last_game_str(...)

      def division_standings = DivisionStandings.new(@subreddit)

      def league_standings = LeagueStandings.new(@subreddit)

      def spring_standings = SpringStandings.new(@subreddit)

      protected

      def schedule
        @schedule ||= Schedule.new(@subreddit)
      end
    end
  end
end

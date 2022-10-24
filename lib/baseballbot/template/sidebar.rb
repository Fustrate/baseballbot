# frozen_string_literal: true

class Baseballbot
  module Template
    class Sidebar < Template::Base
      Dir.glob(File.join(File.dirname(__FILE__), 'sidebar', '*.rb')).each { require _1 }

      def postseason_series_section = Sidebar::Postseason.new(@subreddit).to_s

      def todays_games(date = nil) = Sidebar::TodaysGames.new(@subreddit, date)

      def hitter_stats(...) = Sidebar::Leaders.new(@subreddit).hitter_stats(...)

      def pitcher_stats(...) = Sidebar::Leaders.new(@subreddit).pitcher_stats(...)

      def hitter_stats_table(...) = Sidebar::Leaders.new(@subreddit).hitter_stats_table(...)

      def pitcher_stats_table(...) = Sidebar::Leaders.new(@subreddit).pitcher_stats_table(...)

      def updated_with_link = "[Updated](https://baseballbot.io) #{@subreddit.now.strftime('%-m/%-d at %-I:%M %p %Z')}"

      def inspect = %(#<Baseballbot::Template::Sidebar @subreddit="#{@subreddit.name}">)
    end
  end
end

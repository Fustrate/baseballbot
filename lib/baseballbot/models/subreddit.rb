# frozen_string_literal: true

class Baseballbot
  module Models
    class Subreddit < Sequel::Model(:subreddits)
      one_to_many :game_threads
      one_to_many :templates
      many_to_one :bot

      dataset_module do
        def with_sidebar_enabled = where(Sequel.lit("options['sidebar']['enabled']::boolean IS TRUE"))

        def with_game_threads_enabled = where(Sequel.lit("options['game_threads']['enabled']::boolean IS TRUE"))

        def with_pregame_enabled = where(Sequel.lit("options['pregame']['enabled']::boolean IS TRUE"))

        def with_postgame_enabled = where(Sequel.lit("options['postgame']['enabled']::boolean IS TRUE"))

        def with_offday_enabled = where(Sequel.lit("options['off_day']['enabled']::boolean IS TRUE"))

        def with_unposted_off_day_thread
          with_offday_enabled.where(Sequel.lit(<<~SQL))
            (options['off_day']['last_run_at'] IS NULL OR DATE(options['off_day']['last_run_at']::text) < CURRENT_DATE)
            AND
            ((CURRENT_DATE + options['off_day']['post_at']::text::interval) < NOW() AT TIME ZONE (options->>'timezone'))
          SQL
        end
      end

      # If the bot isn't a moderator of the subreddit, it can't perform some actions
      def moderator? = moderators.include?(bot.name.downcase)

      def sticky_game_threads? = moderator? && options.dig(:game_threads, :sticky) != false

      def now = Baseballbot::Utility.parse_time(Time.now.utc, in_time_zone: timezone)

      def today = now.to_date

      def timezone = options[:timezone] || 'America/Los_Angeles'
    end
  end
end

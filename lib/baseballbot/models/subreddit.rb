# frozen_string_literal: true

class Baseballbot
  module Models
    class Subreddit < Sequel::Model(:subreddits)
      one_to_many :edits, key: :editable_id, reciprocal: :subreddit
      one_to_many :game_threads
      one_to_many :subreddits_users
      one_to_many :templates
      many_to_many :users, join_table: :subreddits_users, left_key: :subreddit_id, right_key: :user_id
      many_to_one :bot

      dataset_module do
        def with_sidebar_enabled = where(Sequel.lit("options['sidebar']['enabled']::boolean IS TRUE"))
      end

      # If the bot isn't a moderator of the subreddit, it can't perform some actions
      def moderator? = moderators.include?(bot.name.downcase)

      def now = Baseballbot::Utility.parse_time(Time.now.utc, in_time_zone: timezone)

      def today = now.to_date

      def timezone = options['timezone'] || 'America/Los_Angeles'
    end
  end
end

# frozen_string_literal: true

class Baseballbot
  module Posts
    class Base
      attr_reader :submission, :template

      def initialize(row, subreddit:)
        @subreddit = subreddit

        @title = row['title']
      end

      def bot
        @subreddit.bot
      end

      def update_flair(flair_id)
        return unless flair_id

        @subreddit.bot.with_reddit_account(@subreddit.account.name) do
          @subreddit.subreddit.set_flair_template(@submission, flair_id)
        end
      end

      def update_sticky(sticky)
        @subreddit.bot.with_reddit_account(@subreddit.account.name) do
          if @submission.stickied?
            @submission.remove_sticky if sticky == false
          elsif sticky
            @submission.make_sticky(slot: @subreddit.options['sticky_slot'])
          end
        end
      end

      def update_suggested_sort(sort = '')
        return if sort == ''

        @subreddit.bot.with_reddit_account(@subreddit.account.name) do
          @submission.set_suggested_sort sort
        end
      end

      protected

      def info(message)
        @subreddit.bot.logger.info(message)
      end
    end
  end
end

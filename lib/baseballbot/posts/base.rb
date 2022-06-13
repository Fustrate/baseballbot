# frozen_string_literal: true

class Baseballbot
  module Posts
    class Base
      attr_reader :submission, :subreddit, :template

      def initialize(subreddit:)
        @subreddit = subreddit
      end

      def bot = @subreddit.bot

      def update_flair(flair_id)
        return unless flair_id

        subreddit.bot.with_reddit_account(subreddit.account.name) do
          subreddit.subreddit.set_flair_template(submission, flair_id)
        end
      end

      def update_sticky(sticky)
        subreddit.bot.with_reddit_account(subreddit.account.name) do
          if submission.stickied?
            submission.remove_sticky if sticky == false
          elsif sticky
            submission.make_sticky(slot: subreddit.options['sticky_slot'])
          end
        end
      end

      def update_suggested_sort(sort = '')
        return if sort == ''

        subreddit.bot.with_reddit_account(subreddit.account.name) do
          submission.set_suggested_sort sort
        end
      end

      def post_comment(text:, sticky: true)
        return unless text && !text.strip.empty?

        with_reddit_account do
          comment = submission.reply text
          comment.distinguish(:sticky) if sticky
        end
      end

      protected

      def info(message) = subreddit.bot.logger.info(message)

      def with_reddit_account(&) = subreddit.bot.with_reddit_account(subreddit.account.name, &)
    end
  end
end

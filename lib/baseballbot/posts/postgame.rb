# frozen_string_literal: true

class Baseballbot
  module Posts
    class Postgame < GameThread
      def create!
        post_thread!

        info "[PST] #{@submission.id} in /r/#{@subreddit.name} for #{@game_pk}"

        @submission
      end

      protected

      def post_thread!
        bot.with_reddit_bot(@subreddit.bot_account.name) do
          @submission = @subreddit.submit(title: template.formatted_title, text: template.evaluated_body, flair_id:)

          post_process
        end
      end

      def template
        @template ||= Templates::PostGameThread.new(subreddit: @subreddit, game_pk: @game_pk, type: 'postgame')
      end

      def post_process
        update_sticky @subreddit.sticky_game_threads?

        bot.sequel[:game_threads].where(id: @id).update(post_game_post_id: @submission.id)

        post_sticky_comment
      end

      def flair_id
        if template.won? && @subreddit.options.dig('postgame', 'flair_id.won')
          return @subreddit.options.dig('postgame', 'flair_id.won')
        end

        if template.lost? && @subreddit.options.dig('postgame', 'flair_id.lost')
          return @subreddit.options.dig('postgame', 'flair_id.lost')
        end

        @subreddit.options.dig('postgame', 'flair_id')
      end

      def post_sticky_comment = post_comment(text: subreddit.options.dig('postgame', 'sticky_comment'))
    end
  end
end

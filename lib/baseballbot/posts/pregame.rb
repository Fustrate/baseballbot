# frozen_string_literal: true

class Baseballbot
  module Posts
    class Pregame < GameThread
      def create!
        post_thread!

        info "[PRE] #{@submission.id} in /r/#{@subreddit.name} for #{@game_pk}"

        @submission
      end

      protected

      def post_thread!
        bot.with_reddit_bot(@subreddit.bot_account.name) do
          @submission = @subreddit.submit(
            title: template.formatted_title,
            text: template.evaluated_body,
            flair_id: @subreddit.options.dig('pregame', 'flair_id')
          )

          post_process
        end
      end

      def template
        @template ||= Templates::PreGameThread.new(
          subreddit: @subreddit,
          game_pk: @game_pk,
          type: 'pregame'
        )
      end

      def post_process
        change_status 'Pregame'

        update_sticky @subreddit.sticky_game_threads?

        Baseballbot::Models::GameThread.where(id: @id).update(pre_game_post_id: @submission.id)

        post_sticky_comment
      end

      def post_sticky_comment = post_comment(text: subreddit.options.dig('pregame', 'sticky_comment'))
    end
  end
end

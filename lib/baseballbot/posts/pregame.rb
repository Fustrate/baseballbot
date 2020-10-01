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
        bot.with_reddit_account(@subreddit.account.name) do
          @submission = @subreddit.submit(
            title: template.formatted_title,
            text: template.evaluated_body
          )

          post_process
        end
      end

      def template
        @template ||= Template::PreGameThread.new(
          subreddit: @subreddit,
          game_pk: @game_pk,
          type: 'pregame'
        )
      end

      def post_process
        change_status 'Pregame'

        update_sticky(sticky: @subreddit.sticky_game_threads?)
        update_flair @subreddit.options.dig('pregame', 'flair')

        bot.db.exec_params(
          'UPDATE game_threads SET pre_game_post_id = $1 WHERE id = $2',
          [@submission.id, @id]
        )
      end
    end
  end
end

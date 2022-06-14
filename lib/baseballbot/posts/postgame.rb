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
        bot.with_reddit_account(@subreddit.account.name) do
          @submission = @subreddit.submit(title: template.formatted_title, text: template.evaluated_body, flair_id:)

          post_process
        end
      end

      def template
        @template ||= Template::PostGameThread.new(subreddit: @subreddit, game_pk: @game_pk, type: 'postgame')
      end

      def post_process
        update_sticky @subreddit.sticky_game_threads?

        bot.db.exec_params 'UPDATE game_threads SET post_game_post_id = $1 WHERE id = $2', [@submission.id, @id]

        post_sticky_comment
      end

      def flair_id
        flair = @subreddit.options.dig('postgame', 'flair_id')

        return unless flair

        return flair['won'] if flair['won'] && template.won?
        return flair['lost'] if flair['lost'] && template.won?

        flair['default']
      end

      def post_sticky_comment = post_comment(text: subreddit.options.dig('postgame', 'sticky_comment'))
    end
  end
end

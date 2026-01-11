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
        bot.with_reddit_bot(@subreddit.bot.name) do
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
        flair = @subreddit.options.dig('postgame', 'flair_id')

        return unless flair

        return flair['won'] if flair['won'] && template.won?
        return flair['lost'] if flair['lost'] && template.lost?

        flair['default']
      end

      def post_sticky_comment = post_comment(text: subreddit.options.dig('postgame', 'sticky_comment'))
    end
  end
end

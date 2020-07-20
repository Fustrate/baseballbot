# frozen_string_literal: true

class Baseballbot
  module Posts
    class Postgame < GameThread
      def initialize(row, subreddit:)
        @id = row['id']
        @game_pk = row['game_pk']

        @subreddit = subreddit
      end

      def create!
        post_thread!

        info "[PST] #{@submission.id} in /r/#{@subreddit.name} for #{@game_pk}"

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
        @template ||= Template::PostGameThread.new(
          subreddit: @subreddit,
          game_pk: @game_pk,
          type: 'postgame'
        )
      end

      def post_process
        update_sticky @subreddit.sticky_game_threads?
        update_flair postgame_flair

        bot.db.exec_params(
          'UPDATE game_threads SET post_game_post_id = $1 WHERE id = $2',
          [@submission.id, @id]
        )
      end

      def postgame_flair
        flairs = @subreddit.options.dig('postgame', 'flair')

        return unless flairs

        return flairs['won'] if template.won? && flairs['won']
        return flairs['lost'] if template.lost? && flairs['lost']

        flairs
      end
    end
  end
end

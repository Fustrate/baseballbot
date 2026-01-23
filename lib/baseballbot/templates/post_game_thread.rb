# frozen_string_literal: true

class Baseballbot
  module Templates
    class PostGameThread < GameThread
      protected

      def default_title
        @subreddit.options.dig('postgame', title_key)

        # # Spring training games can end in a tie.
        # titles['tie'] || titles
      end

      def title_key
        return 'title.won' if won? && @subreddit.options.dig('postgame', 'title.won')

        return 'title.lost' if lost? && @subreddit.options.dig('postgame', 'title.lost')

        if %w[F D L W].include?(game_data.dig('game', 'type')) && @subreddit.options.dig('postgame', 'title.playoffs')
          return 'title.playoffs'
        end

        'title'
      end
    end
  end
end

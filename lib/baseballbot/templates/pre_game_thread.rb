# frozen_string_literal: true

class Baseballbot
  module Templates
    class PreGameThread < GameThread
      protected

      def default_title
        playoffs = %w[F D L W].include?(game_data.dig('game', 'type'))

        if playoffs && @subreddit.options.dig('pregame', 'title.postseason')
          return @subreddit.options.dig('pregame', 'title.postseason')
        end

        @subreddit.options.dig('pregame', 'title')
      end
    end
  end
end

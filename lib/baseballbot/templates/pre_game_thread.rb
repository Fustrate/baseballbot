# frozen_string_literal: true

class Baseballbot
  module Templates
    class PreGameThread < GameThread
      protected

      def default_title
        titles = @subreddit.options.dig('pregame', 'title')

        return titles if titles.is_a?(String)

        playoffs = %w[F D L W].include? game_data.dig('game', 'type')

        titles[playoffs ? 'postseason' : 'default'] || titles.values.first
      end
    end
  end
end

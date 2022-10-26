# frozen_string_literal: true

class Baseballbot
  module Templates
    class PostGameThread < GameThread
      protected

      def default_title
        titles = @subreddit.options.dig('postgame', 'title')

        return titles if titles.is_a?(String)

        titles[title_key] || titles['default'] || titles.values.first

        # # Spring training games can end in a tie.
        # titles['tie'] || titles
      end

      def title_key
        return 'won' if won?

        return 'lost' if lost?

        return 'playoffs' if %w[F D L W].include? game_data.dig('game', 'type')

        'default'
      end
    end
  end
end

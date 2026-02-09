# frozen_string_literal: true

# This template is only used when initially posting a no-hitter thread. Updates
# are handled like normal game threads.
class Baseballbot
  module Templates
    class NoHitter < GameThread
      TITLE_FORMAT = 'No-H****r Alert - {{pitcher_names}} ({{pitching_team}}) vs. {{batting_team}}'

      # The title formatter needs to know this
      attr_reader :flag

      def initialize(subreddit:, game_pk:, flag:)
        @flag = flag

        super(subreddit:, game_pk:, title: TITLE_FORMAT, type: 'no_hitter')
      end

      def instance_variables_to_inspect = super + %i[@flag]
    end
  end
end

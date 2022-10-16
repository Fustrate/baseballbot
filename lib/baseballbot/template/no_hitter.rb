# frozen_string_literal: true

# This template is only used when initially posting a no-hitter thread. Updates
# are handled like normal game threads.
class Baseballbot
  module Template
    class NoHitter < GameThread
      TITLE_FORMAT = 'No-H****r Alert - %<pitcher_names>s (%<pitching_team>s) vs. %<batting_team>s'

      def initialize(subreddit:, game_pk:, flag:)
        @flag = flag

        super(subreddit:, game_pk:, title: TITLE_FORMAT, type: 'no_hitter')
      end

      def inspect = %(#<Baseballbot::Template::NoHitter @game_pk="#{@game_pk}" @flag="#{@flag}">)

      protected

      def title_interpolations
        super.merge(
          pitcher_names:,
          pitching_team: @flag == 'home' ? home_team.name : away_team.name,
          batting_team: @flag == 'home' ? away_team.name : home_team.name
        )
      end

      def pitcher_names
        (@flag == 'home' ? home_pitchers : away_pitchers)
          .map { player_name(_1) }
          .join(', ')
      end
    end
  end
end

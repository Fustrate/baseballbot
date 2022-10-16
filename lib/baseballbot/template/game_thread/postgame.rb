# frozen_string_literal: true

class Baseballbot
  module Template
    class GameThread
      module Postgame
        def decisions_table
          table(
            headers: [['Winning Pitcher', :center], ['Losing Pitcher', :center], ['Save', :center]],
            rows: [winning_pitcher, losing_pitcher, save_pitcher]
          )
        end

        protected

        def winner_flag = (runs(:home) > runs(:away) ? 'home' : 'away')

        def loser_flag = (runs(:home) > runs(:away) ? 'away' : 'home')

        def winning_pitcher
          return unless final?

          pitcher_id = feed.dig('liveData', 'decisions', 'winner', 'id')

          return unless pitcher_id

          data = boxscore.dig 'teams', winner_flag, 'players', "ID#{pitcher_id}"

          format(
            '%<name>s (%<record>s, %<era>s ERA)',
            name: player_name(data),
            record: data['seasonStats']['pitching'].values_at('wins', 'losses').join('-'),
            era: data['seasonStats']['pitching']['era']
          )
        end

        def losing_pitcher
          return unless final?

          pitcher_id = feed.dig('liveData', 'decisions', 'loser', 'id')

          return unless pitcher_id

          data = boxscore.dig 'teams', loser_flag, 'players', "ID#{pitcher_id}"

          format(
            '%<name>s (%<record>s, %<era>s ERA)',
            name: player_name(data),
            record: data['seasonStats']['pitching'].values_at('wins', 'losses').join('-'),
            era: data['seasonStats']['pitching']['era']
          )
        end

        def save_pitcher
          return unless final?

          pitcher_id = feed.dig('liveData', 'decisions', 'save', 'id')

          return unless pitcher_id

          data = boxscore.dig 'teams', winner_flag, 'players', "ID#{pitcher_id}"

          format(
            '%<name>s (%<saves>s SV, %<era>s ERA)',
            name: player_name(data),
            saves: data['seasonStats']['pitching']['saves'],
            era: data['seasonStats']['pitching']['era']
          )
        end
      end
    end
  end
end

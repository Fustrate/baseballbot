# frozen_string_literal: true

class Baseballbot
  module Template
    class GameThread
      module Pitchers
        PITCHER_COLUMNS = {
          ip: ->(_, game) { game['inningsPitched'] },
          h: ->(_, game) { game['hits'] },
          r: ->(_, game) { game['runs'] },
          er: ->(_, game) { game['earnedRuns'] },
          bb: ->(_, game) { game['baseOnBalls'] },
          so: ->(_, game) { game['strikeOuts'] },
          'p-s': ->(_, game) { "#{game['pitchesThrown']}-#{game['strikes']}" },
          era: ->(pitcher, _) { pitcher['seasonStats']['pitching']['era'] }
        }.freeze

        def probable_away_starter
          pitcher_id = game_data.dig('probablePitchers', 'away', 'id')

          boxscore.dig('teams', 'away', 'players', "ID#{pitcher_id}") if pitcher_id
        end

        def probable_home_starter
          pitcher_id = game_data.dig('probablePitchers', 'home', 'id')

          boxscore.dig('teams', 'home', 'players', "ID#{pitcher_id}") if pitcher_id
        end

        def pitchers_table(flag, stats: %i[ip h r er bb so p-s era])
          pitchers = team_pitchers(flag)

          return if pitchers.none?

          table(headers: pitchers_table_header(flag, stats), rows: pitchers.map { pitcher_row(_1, stats) })
        end

        protected

        def team_pitchers(flag)
          return [] unless started? && boxscore

          boxscore.dig('teams', flag.to_s, 'pitchers').map { boxscore.dig('teams', flag.to_s, 'players', "ID#{_1}") }
        end

        def pitchers_table_header(flag, stats)
          [bold((flag == :home ? home_team : away_team).code), *(stats.map { [_1.to_s.upcase, :center] })]
        end

        def pitcher_row(pitcher, stats = %i[ip h r er bb so p-s era])
          today = game_stats(pitcher)['pitching']

          [player_link(pitcher, title: 'Game Score: ???'), *(stats.map { PITCHER_COLUMNS[_1].call(pitcher, today) })]
        end

        def pitcher_line(pitcher)
          return 'TBA' unless pitcher

          format '[%<name>s](%<url>s) (%<wins>d-%<losses>d, %<era>s ERA)',
                 name: pitcher.dig('person', 'fullName'),
                 url: player_url(pitcher.dig('person', 'id')),
                 wins: pitcher.dig('seasonStats', 'pitching', 'wins').to_i,
                 losses: pitcher.dig('seasonStats', 'pitching', 'losses').to_i,
                 era: pitcher.dig('seasonStats', 'pitching', 'era')
        end
      end
    end
  end
end

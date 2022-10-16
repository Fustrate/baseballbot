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

        def home_pitchers
          return [] unless started? && boxscore

          boxscore.dig('teams', 'home', 'pitchers').map { boxscore.dig('teams', 'home', 'players', "ID#{_1}") }
        end

        def away_pitchers
          return [] unless started? && boxscore

          boxscore.dig('teams', 'away', 'pitchers').map { boxscore.dig('teams', 'away', 'players', "ID#{_1}") }
        end

        def pitchers = full_zip(home_pitchers, away_pitchers)

        def pitchers_table(stats: %i[ip h r er bb so p-s era])
          rows = pitchers.map do |one, two|
            [pitcher_row(one, stats), pitcher_row(two, stats)].join('||')
          end

          stat_alignment = ([':-:'] * stats.count).join('|')

          <<~MARKDOWN
            #{pitchers_table_header(home_team, stats)}||#{pitchers_table_header(away_team, stats)}
            -|#{stat_alignment}|-|-|#{stat_alignment}
            #{rows.join("\n")}
          MARKDOWN
        end

        def home_pitchers_table(stats: %i[ip h r er bb so p-s era])
          rows = home_pitchers.map { pitcher_row(_1, stats) }

          <<~MARKDOWN
            #{pitchers_table_header(home_team, stats)}
            -|#{([':-:'] * stats.count).join('|')}
            #{rows.join("\n")}
          MARKDOWN
        end

        def away_pitchers_table(stats: %i[ip h r er bb so p-s era])
          rows = away_pitchers.map { pitcher_row(_1, stats) }

          <<~MARKDOWN
            #{pitchers_table_header(away_team, stats)}
            -|#{([':-:'] * stats.count).join('|')}
            #{rows.join("\n")}
          MARKDOWN
        end

        def pitchers_table_header(team, stats) = "**#{team.code}**|#{stats.map(&:to_s).map(&:upcase).join('|')}"

        def pitcher_row(pitcher, stats = %i[ip h r er bb so p-s era])
          return " #{'|' * stats.count}" unless pitcher

          today = game_stats(pitcher)['pitching']

          cells = stats.map { PITCHER_COLUMNS[_1].call(pitcher, today) }

          [player_link(pitcher, title: 'Game Score: ???'), *cells].join '|'
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

# frozen_string_literal: true

class Baseballbot
  module Templates
    module GameThreads
      module Components
        class PitchersTable
          include MarkdownHelpers

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

          def initialize(game_thread, team, stats: %i[ip h r er bb so p-s era])
            @game_thread = game_thread
            @team = team
            @stats = stats
          end

          def to_s
            return '' unless @game_thread.started? && @game_thread.boxscore && pitchers.any?

            table(headers: table_header, rows: pitchers.map { pitcher_row(it) })
          end

          protected

          def pitchers
            @pitchers ||= begin
              team_info = @game_thread.boxscore['teams'].find { |_, v| v.dig('team', 'id') == @team.id }[1]

              team_info['pitchers'].map { team_info.dig('players', "ID#{it}") }
            end
          end

          def table_header = ["**#{@team.code}**", *(@stats.map { [it.to_s.upcase, :center] })]

          def pitcher_row(pitcher)
            game = game_stats(pitcher)['pitching']

            title = starting_pitcher?(pitcher) ? "Game Score: #{tom_tango_game_score(game)}" : nil

            [player_link(pitcher, title:), *(@stats.map { PITCHER_COLUMNS[it].call(pitcher, game) })]
          end

          def starting_pitcher?(pitcher)
            pitcher.dig('person', 'id') == @game_thread.game_data.dig('probablePitchers', 'home', 'id') ||
              pitcher.dig('person', 'id') == @game_thread.game_data.dig('probablePitchers', 'away', 'id')
          end

          def game_stats(player) = player['gameStats'] || player['stats'] || {}

          def bill_james_game_score(game)
            [
              50,
              game['outs'],
              2 * innings_after_fourth(game),
              game['strikeOuts'],
              -2 * game['hits'],
              -4 * game['earnedRuns'],
              -2 * (game['runs'] - game['unearnedRuns']),
              -game['baseOnBalls']
            ].sum
          end

          def innings_after_fourth(game) = [(game['outs'] - 12), 0].max / 3

          # This is the game score MLB shows on their site - https://blogs.fangraphs.com/instagraphs/game-score-v2-0/
          def tom_tango_game_score(game)
            [
              40,
              2 * game['outs'],
              game['strikeOuts'],
              -2 * game['baseOnBalls'],
              -2 * game['hits'],
              -3 * game['runs'],
              -4 * game['homeRuns']
            ].sum
          end
        end
      end
    end
  end
end

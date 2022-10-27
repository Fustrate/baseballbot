# frozen_string_literal: true

class Baseballbot
  module Templates
    module GameThreads
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

        attr_reader :template

        def initialize(template, team, stats: %i[ip h r er bb so p-s era])
          @template = template
          @team = team
          @stats = stats
        end

        def to_s
          return unless template.started? && template.boxscore && pitchers.any?

          table(headers: table_header, rows: pitchers.map { pitcher_row(_1) })
        end

        protected

        def pitchers
          @pitchers ||= begin
            team_info = template.boxscore['teams'].find { |_, v| v.dig('team', 'id') == @team.id }[1]

            team_info['pitchers'].map { team_info.dig('players', "ID#{_1}") }
          end
        end

        def table_header = ["**#{@team.code}**", *(@stats.map { [_1.to_s.upcase, :center] })]

        def pitcher_row(pitcher)
          game = game_stats(pitcher)['pitching']

          title = starting_pitcher?(pitcher) ? "Game Score: #{tom_tango_game_score(game)}" : nil

          [player_link(pitcher, title:), *(@stats.map { PITCHER_COLUMNS[_1].call(pitcher, game) })]
        end

        def starting_pitcher?(pitcher)
          pitcher.dig('person', 'id') == @template.game_data.dig('probablePitchers', 'home', 'id') ||
            pitcher.dig('person', 'id') == @template.game_data.dig('probablePitchers', 'away', 'id')
        end

        def game_stats(player) = (player['gameStats'] || player['stats'] || {})

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

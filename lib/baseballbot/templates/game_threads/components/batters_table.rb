# frozen_string_literal: true

class Baseballbot
  module Templates
    module GameThreads
      module Components
        class BattersTable
          include MarkdownHelpers

          BATTER_COLUMNS = {
            ab: ->(_, game) { game['atBats'] },
            r: ->(_, game) { game['runs'] },
            h: ->(_, game) { game['hits'] },
            rbi: ->(_, game) { game['rbi'] },
            bb: ->(_, game) { game['baseOnBalls'] },
            so: ->(_, game) { game['strikeOuts'] },
            ba: ->(batter, _) { batter['seasonStats']['batting']['avg'] },
            sb: ->(_, game) { game['stolenBases'] }
          }.freeze

          def initialize(game_thread, team, stats: %i[ab r h rbi bb so ba])
            @game_thread = game_thread
            @team = team
            @stats = stats
          end

          def to_s
            return '' unless @game_thread.started? && @game_thread.boxscore && batters.any?

            table(headers: table_header, rows: batters.map { batter_row(_1) })
          end

          protected

          def batters
            @batters ||= @game_thread.boxscore['teams']
              .find { |_, v| v.dig('team', 'id') == @team.id }
              .dig(1, 'players')
              .values
              .select { batting_order(_1).positive? }
              .sort_by { batting_order(_1) }
          end

          def table_header = ["**#{@team.code}**", ' ', *(@stats.map { [_1.to_s.upcase, :center] })]

          def batter_row(batter)
            # Batting order shows as [1-9]00 for the starter, and adds 1 for each substitution (e.g. 400 -> 401 -> 402)
            replacement = (batting_order(batter) % 100).positive?
            position = batter['position']['abbreviation']

            spacer = '[](/spacer)' if replacement

            [
              "#{spacer}#{replacement ? position : "**#{position}**"}",
              "#{spacer}#{player_link(batter)}",
              *batter_stats(batter)
            ]
          end

          def batter_stats(batter)
            today = game_stats(batter)['batting']

            @stats.map { BATTER_COLUMNS[_1].call(batter, today) }
          end

          def batting_order(batter) = (batter['battingOrder'] || game_stats(batter).dig('batting', 'battingOrder')).to_i

          def game_stats(player) = player['gameStats'] || player['stats'] || {}
        end
      end
    end
  end
end

# frozen_string_literal: true

class Baseballbot
  module Template
    class GameThread
      module Batters
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

        def batters_table(flag, stats: %i[ab r h rbi bb so ba])
          table headers: batters_table_header(flag, stats), data: team_batters(flag).map { batter_row(_1, stats) }
        end

        protected

        def team_batters(flag)
          return [] unless started? && boxscore

          boxscore['teams'][flag.to_s]['players']
            .values
            .select { batting_order(_1).positive? }
            .sort_by { batting_order(_1) }
        end

        def batters_table_header(flag, stats)
          [bold((flag == :home ? home_team : away_team).code), ' ', *(stats.map { [_1.to_s.upcase, :center] })]
        end

        def batter_row(batter, stats = %i[ab r h rbi bb so ba])
          # Batting order shows as [1-9]00 for the starter, and adds 1 for each substitution (e.g. 400 -> 401 -> 402)
          replacement = (batting_order(batter) % 100).positive?
          position = batter['position']['abbreviation']

          spacer = '[](/spacer)' if replacement
          position = bold(position) unless replacement

          ["#{spacer}#{position}", "#{spacer}#{player_link(batter)}", *batter_cells(batter, stats)]
        end

        def batter_cells(batter, stats)
          today = game_stats(batter)['batting']

          stats.map { BATTER_COLUMNS[_1].call(batter, today) }
        end

        def batting_order(batter)
          batter['battingOrder']&.to_i || game_stats(batter).dig('batting', 'battingOrder').to_i
        end
      end
    end
  end
end

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
          ba: ->(season, _) { season['seasonStats']['batting']['avg'] },
          sb: ->(_, game) { game['stolenBases'] }
        }.freeze

        def batting_order(batter)
          return batter['battingOrder'].to_i if batter['battingOrder']

          game_stats(batter).dig('batting', 'battingOrder').to_i
        end

        def home_batters
          return [] unless started? && boxscore

          @home_batters ||= boxscore['teams']['home']['players']
            .values
            .select { |batter| batting_order(batter).positive? }
            .sort_by { |batter| batting_order batter }
        end

        def away_batters
          return [] unless started? && boxscore

          @away_batters ||= boxscore['teams']['away']['players']
            .values
            .select { |batter| batting_order(batter).positive? }
            .sort_by { |batter| batting_order batter }
        end

        def batters
          full_zip home_batters, away_batters
        end

        def batters_table(stats: %i[ab r h rbi bb so ba])
          rows = batters.map do |one, two|
            [batter_row(one, stats), batter_row(two, stats)].join('||')
          end

          <<~TABLE
            #{table_header(home_team, stats)}||#{table_header(away_team, stats)}
            -|-#{'|:-:' * stats.count}|-|-|-#{'|:-:' * stats.count}
            #{rows.join("\n")}
          TABLE
        end

        def home_batters_table(stats: %i[ab r h rbi bb so ba])
          rows = home_batters.map { |batter| batter_row(batter, stats) }

          <<~TABLE
            #{table_header(home_team, stats)}
            -|-#{'|:-:' * stats.count}
            #{rows.join("\n")}
          TABLE
        end

        def away_batters_table(stats: %i[ab r h rbi bb so ba])
          rows = away_batters.map { |batter| batter_row(batter, stats) }

          <<~TABLE
            #{table_header(away_team, stats)}
            -|-#{'|:-:' * stats.count}
            #{rows.join("\n")}
          TABLE
        end

        def table_header(team, stats)
          "**#{team.code}**|#{stats.map(&:to_s).map(&:upcase).join('|')}"
        end

        def batter_row(batter, stats = %i[ab r h rbi bb so ba])
          return " |#{'|' * stats.count}" unless batter

          replacement = (batting_order(batter) % 100).positive?
          spacer = '[](/spacer)' if replacement
          position = batter['position']['abbreviation']

          position = bold(position) unless replacement

          [
            "#{spacer}#{position}",
            "#{spacer}#{player_link(batter)}",
            *batter_cells(batter, stats)
          ].join('|')
        end

        def batter_cells(batter, stats)
          today = game_stats(batter)['batting']

          stats.map { |stat| BATTER_COLUMNS[stat].call(batter, today) }
        end
      end
    end
  end
end

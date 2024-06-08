# frozen_string_literal: true

class Baseballbot
  module Templates
    module GameThreads
      module Components
        class Matchups
          include MarkdownHelpers

          BASE_URL = 'https://bdfed.stitch.mlbinfra.com/bdfed/matchup/%<game_pk>s?statList=avg&statList=atBats' \
                     '&statList=homeRuns&statList=rbi&statList=ops&statList=strikeOuts'

          HEADERS = %w[AVG OPS AB HR RBI K].freeze

          def initialize(game_thread)
            @game_thread = game_thread
          end

          def to_s = "#{home_table}\n\n#{away_table}"

          protected

          def home_table
            table(
              headers: [
                "#{data.dig('probables', 'homeAbbreviation')} vs. #{data.dig('probables', 'awayProbableLastName')}",
                *HEADERS
              ],
              rows: data['home'].map { [_1['boxscoreName'], *player_stats(_1)] }
            )
          end

          def away_table
            table(
              headers: [
                "#{data.dig('probables', 'awayAbbreviation')} vs. #{data.dig('probables', 'homeProbableLastName')}",
                *HEADERS
              ],
              rows: data['away'].map { [_1['boxscoreName'], *player_stats(_1)] }
            )
          end

          def player_row(player)
            return ['-'] * 6 unless player['stats']

            player['stats'].values_at('avg', 'ops', 'atBats', 'homeRuns', 'rbi', 'strikeOuts')
          end

          def data
            @data ||= JSON.parse(URI.parse(format(BASE_URL, game_pk: @game_thread.game_pk)).open.read)
          end
        end
      end
    end
  end
end

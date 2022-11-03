# frozen_string_literal: true

class Baseballbot
  module Templates
    module GameThreads
      module Components
        class BoxScore
          include MarkdownHelpers

          def initialize(game_thread)
            @game_thread = game_thread
          end

          def to_s
            tables = batter_and_pitcher_tables.compact

            <<~MARKDOWN.strip
              ### Box Score

              #{tables.any? ? tables.join("\n\n") : 'Lineups will be posted closer to game time.'}
            MARKDOWN
          end

          protected

          def batter_and_pitcher_tables
            [
              batters_table(@game_thread.home_team),
              pitchers_table(@game_thread.home_team),
              batters_table(@game_thread.away_team),
              pitchers_table(@game_thread.away_team)
            ]
          end

          def batters_table(team) = BattersTable.new(@game_thread, team).to_s

          def pitchers_table(team) = PitchersTable.new(@game_thread, team).to_s
        end
      end
    end
  end
end

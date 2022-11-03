# frozen_string_literal: true

class Baseballbot
  module Templates
    module GameThreads
      module Components
        class Decisions
          include MarkdownHelpers

          TABLE_HEADERS = [['Winning Pitcher', :center], ['Losing Pitcher', :center], ['Save', :center]].freeze

          def initialize(game_thread)
            @game_thread = game_thread
          end

          def to_s
            return '' unless @game_thread.final? && @game_thread.linescore

            @winner_flag, @loser_flag = winner_and_loser_flags

            <<~MARKDOWN.strip
              ### Decisions

              #{table(headers: TABLE_HEADERS, rows: [[winning_pitcher, losing_pitcher, save_pitcher]])}
            MARKDOWN
          end

          protected

          def winner_and_loser_flags
            teams = @game_thread.linescore['teams']

            (teams.dig('home', 'runs') || 0) > (teams.dig('away', 'runs') || 0) ? %w[home away] : %w[away home]
          end

          # The player info in game_data.players doesn't include pitching stats
          def winning_pitcher
            pitcher_id = @game_thread.feed.dig('liveData', 'decisions', 'winner', 'id')

            return unless pitcher_id

            pitcher = @game_thread.boxscore.dig('teams', @winner_flag, 'players', "ID#{pitcher_id}")

            format '%<name>s (%<record>s, %<era>s ERA)', name: name(pitcher), record: record(pitcher), era: era(pitcher)
          end

          def losing_pitcher
            pitcher_id = @game_thread.feed.dig('liveData', 'decisions', 'loser', 'id')

            return unless pitcher_id

            pitcher = @game_thread.boxscore.dig('teams', @loser_flag, 'players', "ID#{pitcher_id}")

            format '%<name>s (%<record>s, %<era>s ERA)', name: name(pitcher), record: record(pitcher), era: era(pitcher)
          end

          def record(pitcher) = pitcher['seasonStats']['pitching'].values_at('wins', 'losses').join('-')

          def save_pitcher
            pitcher_id = @game_thread.feed.dig('liveData', 'decisions', 'save', 'id')

            return unless pitcher_id

            pitcher = @game_thread.boxscore.dig('teams', @winner_flag, 'players', "ID#{pitcher_id}")

            format '%<name>s (%<saves>s SV, %<era>s ERA)', name: name(pitcher), saves: saves(pitcher), era: era(pitcher)
          end

          def name(pitcher)
            return 'TBA' unless pitcher

            pitcher['boxscoreName'] ||
              pitcher.dig('name', 'boxscore') ||
              @game_thread.game_data.dig('players', "ID#{pitcher['person']['id']}", 'boxscoreName')
          end

          def era(pitcher) = pitcher['seasonStats']['pitching']['era']

          def saves(pitcher) = pitcher['seasonStats']['pitching']['saves']
        end
      end
    end
  end
end

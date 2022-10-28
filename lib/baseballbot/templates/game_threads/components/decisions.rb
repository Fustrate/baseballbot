# frozen_string_literal: true

class Baseballbot
  module Templates
    module GameThreads
      module Components
        class Decisions
          include MarkdownHelpers

          TABLE_HEADERS = [['Winning Pitcher', :center], ['Losing Pitcher', :center], ['Save', :center]].freeze

          attr_reader :template

          def initialize(template)
            @template = template
          end

          def to_s
            return '' unless template.final? && template.linescore

            @winner_flag, @loser_flag = winner_and_loser_flags

            <<~MARKDOWN.strip
              ### Decisions

              #{table(headers: TABLE_HEADERS, rows: [[winning_pitcher, losing_pitcher, save_pitcher]])}
            MARKDOWN
          end

          protected

          def winner_and_loser_flags
            teams = template.linescore['teams']

            (teams.dig('home', 'runs') || 0) > (teams.dig('away', 'runs') || 0) ? %w[home away] : %w[away home]
          end

          # The player info in game_data.players doesn't include pitching stats
          def winning_pitcher
            pitcher_id = template.feed.dig('liveData', 'decisions', 'winner', 'id')

            return unless pitcher_id

            pitcher = template.boxscore.dig('teams', @winner_flag, 'players', "ID#{pitcher_id}")

            format('%<name>s (%<record>s, %<era>s ERA)', name: name(pitcher), record: record(pitcher), era: era(pitcher))
          end

          def losing_pitcher
            pitcher_id = template.feed.dig('liveData', 'decisions', 'loser', 'id')

            return unless pitcher_id

            pitcher = template.boxscore.dig('teams', @loser_flag, 'players', "ID#{pitcher_id}")

            format('%<name>s (%<record>s, %<era>s ERA)', name: name(pitcher), record: record(pitcher), era: era(pitcher))
          end

          def record(pitcher) = pitcher['seasonStats']['pitching'].values_at('wins', 'losses').join('-')

          def save_pitcher
            pitcher_id = template.feed.dig('liveData', 'decisions', 'save', 'id')

            return unless pitcher_id

            pitcher = template.boxscore.dig('teams', @winner_flag, 'players', "ID#{pitcher_id}")

            format('%<name>s (%<saves>s SV, %<era>s ERA)', name: name(pitcher), saves: saves(pitcher), era: era(pitcher))
          end

          def name(pitcher) = template.player_name(pitcher)

          def era(pitcher) = pitcher['seasonStats']['pitching']['era']

          def saves(pitcher) = pitcher['seasonStats']['pitching']['saves']
        end
      end
    end
  end
end

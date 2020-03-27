# frozen_string_literal: true

class Baseballbot
  module Template
    class GameThread
      module LineScore
        BLANK_RHE = { 'runs' => 0, 'hits' => 0, 'errors' => 0 }.freeze
        BLANK_LINES = [[nil] * 9, [nil] * 9].freeze

        def line_score
          [
            "| |#{(1..(lines[0].count)).to_a.join('|')}|R|H|E",
            "|:-:|#{(':-:|' * lines[0].count)}:-:|:-:|:-:",
            line_for_team(:away),
            line_for_team(:home)
          ].join "\n"
        end

        def line_score_status
          return game_data.dig('status', 'detailedState') unless live?

          return inning if outs == 3

          "#{runners}, #{outs} #{outs == 1 ? 'Out' : 'Outs'}, #{inning}"
        end

        def home_rhe
          return BLANK_RHE unless linescore&.dig('teams', 'home', 'runs')

          linescore.dig('teams', 'home')
        end

        def away_rhe
          return BLANK_RHE unless linescore&.dig('teams', 'away', 'runs')

          linescore.dig('teams', 'away')
        end

        def home_lob
          boxscore.dig('teams', 'home', 'info')
            .find { |info| info['title'] == 'BATTING' }
            .dig('fieldList')
            .find { |stat| stat['label'] == 'Team LOB' }
            .dig('value')
            .to_i
        end

        def away_lob
          boxscore.dig('teams', 'away', 'info')
            .find { |info| info['title'] == 'BATTING' }
            .dig('fieldList')
            .find { |stat| stat['label'] == 'Team LOB' }
            .dig('value')
            .to_i
        end

        protected

        def lines
          @lines ||= begin
            return BLANK_LINES unless started? && linescore&.dig('innings')

            process_linescore_inning
          end
        end

        def process_linescore_inning
          lines = base_lines

          linescore['innings'].each do |inning|
            lines[0][inning['num'] - 1] = inning['away']&.dig('runs')
            lines[1][inning['num'] - 1] = inning['home']&.dig('runs')
          end

          lines
        end

        def base_lines
          innings = [9, linescore['innings'].count].max

          [[nil] * innings, [nil] * innings]
        end

        def line_for_team(flag)
          info = team_line_information(flag)

          format(
            '|[%<code>s](/%<code>s)|%<line>s|%<runs>s|%<hits>s|%<errors>s',
            code: info[:code],
            line: info[:line].join('|'),
            runs: bold(info[:runs]),
            hits: bold(info[:hits]),
            errors: bold(info[:errors])
          )
        end

        def team_line_information(flag)
          rhe = flag == :home ? home_rhe : away_rhe

          {
            code: (flag == :home ? home_team : away_team).code,
            line: flag == :home ? lines[1] : lines[0],
            runs: rhe['runs'],
            hits: rhe['hits'],
            errors: rhe['errors']
          }
        end
      end
    end
  end
end

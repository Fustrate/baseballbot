# frozen_string_literal: true

class Baseballbot
  module Template
    class GameThread
      module LineScore
        BLANK_RHE = { 'runs' => 0, 'hits' => 0, 'errors' => 0 }.freeze
        BLANK_LINES = [[nil] * 9, [nil] * 9].freeze

        def line_score_section
          <<~MARKDOWN
            ### Line Score - #{line_score_status}

            #{line_score}
          MARKDOWN
        end

        def line_score
          <<~MARKDOWN
            | |#{(1..(line_score_innings[0].count)).to_a.join('|')}|R|H|E|LOB
            |:-:|#{':-:|' * line_score_innings[0].count}:-:|:-:|:-:|:-:
            #{line_score_team(:away)}
            #{line_score_team(:home)}
          MARKDOWN
        end

        def line_score_status
          return game_data.dig('status', 'detailedState') unless live?

          return inning if outs == 3

          "#{runners}, #{outs} #{outs == 1 ? 'Out' : 'Outs'}, #{inning}"
        end

        def runs(flag) = rhe(flag)['runs']

        protected

        def line_score_innings
          @line_score_innings ||= started? && linescore&.dig('innings') ? process_line_score_inning : BLANK_LINES
        end

        def process_line_score_inning
          base_lines.tap do |lines|
            linescore['innings'].each do |inning|
              lines[0][inning['num'] - 1] = inning_runs(inning, 'away')
              lines[1][inning['num'] - 1] = inning_runs(inning, 'home')
            end
          end
        end

        def inning_runs(inning, flag) = inning[flag]&.dig('runs')

        def base_lines
          innings = [9, linescore['innings'].count].max

          [[nil] * innings, [nil] * innings]
        end

        def line_score_team(flag)
          info = team_line_information(flag)

          format(
            '|[%<code>s](/%<code>s)|%<line>s|%<runs>s|%<hits>s|%<errors>s|%<lob>s',
            code: info[:code],
            line: info[:line].join('|'),
            runs: bold(info[:runs]),
            hits: bold(info[:hits]),
            errors: bold(info[:errors]),
            lob: bold(lob(flag))
          )
        end

        def team_line_information(flag)
          team_rhe = rhe(flag)

          {
            code: (flag == :home ? home_team : away_team).code,
            line: flag == :home ? line_score_innings[1] : line_score_innings[0],
            runs: team_rhe['runs'],
            hits: team_rhe['hits'],
            errors: team_rhe['errors']
          }
        end

        def rhe(flag) = linescore&.dig('teams', flag.to_s, 'runs') ? linescore.dig('teams', flag.to_s) : BLANK_RHE

        def lob(flag)
          return ' ' unless started?

          boxscore.dig('teams', flag.to_s, 'info')
            .find { _1['title'] == 'BATTING' }['fieldList']
            .find { _1['label'] == 'Team LOB' }['value']
            .to_i
        end
      end
    end
  end
end

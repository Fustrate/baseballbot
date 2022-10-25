# frozen_string_literal: true

class Baseballbot
  module Template
    class GameThread
      class LineScore
        include MarkdownHelpers

        BLANK_RHE = { 'runs' => 0, 'hits' => 0, 'errors' => 0 }.freeze
        BLANK_LINES = [[nil] * 9, [nil] * 9].freeze

        attr_reader :template

        def initialize(template)
          @template = template
        end

        def to_s
          <<~MARKDOWN.strip
            ### Line Score - #{line_score_status}

            #{table(headers: table_headers, rows: table_rows)}
          MARKDOWN
        end

        protected

        def table_headers = [' ', *[*line_score_inning_numbers, 'R', 'H', 'E', 'LOB'].map { [_1, :center] }]

        def table_rows = [line_score_team(:away), line_score_team(:home)]

        def line_score_status
          return template.game_data.dig('status', 'detailedState') unless template.live?

          template.outs == 3 ? template.inning : "#{template.runners}, #{line_score_outs}, #{template.inning}"
        end

        def line_score_outs = "#{template.outs} #{template.outs == 1 ? 'Out' : 'Outs'}"

        def line_score_innings(flag)
          template.started? && template.linescore&.dig('innings') ? team_inning_scores(flag.to_s) : BLANK_LINES
        end

        def team_inning_scores(flag) = [*played_inning_runs(flag), *([' '] * 9)].first(innings)

        def played_inning_runs(flag) = template.linescore['innings'].sort_by { _1['num'] }.map { _1.dig(flag, 'runs') }

        def innings = [9, template.linescore['innings'].count].max

        def line_score_team(flag)
          team_rhe = rhe(flag)

          [
            (flag == :home ? template.home_team : template.away_team).code,
            *line_score_innings(flag),
            "**#{team_rhe['runs']}**",
            "**#{team_rhe['hits']}**",
            "**#{team_rhe['errors']}**",
            "**#{lob(flag)}**"
          ]
        end

        def line_score_inning_numbers = (1..innings).to_a

        def rhe(flag)
          template.linescore&.dig('teams', flag.to_s, 'runs') ? template.linescore.dig('teams', flag.to_s) : BLANK_RHE
        end

        def runs(flag) = rhe(flag)['runs']

        # This is surprisingly complicated. I'm going to guess they'll move this info in the next few seasons.
        def lob(flag)
          return '-' unless template.started?

          batting_info = template.boxscore.dig('teams', flag.to_s, 'info')&.find { _1['title'] == 'BATTING' }

          return '-' unless batting_info

          lob_info = batting_info['fieldList'].find { _1['label'] == 'Team LOB' }

          lob_info ? lob_info['value'].to_i : 0
        end
      end
    end
  end
end

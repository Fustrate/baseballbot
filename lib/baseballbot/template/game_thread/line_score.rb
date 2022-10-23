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

            #{line_score_table.strip}
          MARKDOWN
        end

        protected

        def line_score_table
          table(
            headers: [' ', *[*line_score_inning_numbers, 'R', 'H', 'E', 'LOB'].map { [_1, :center] }],
            rows: [line_score_team(:away), line_score_team(:home)]
          )
        end

        def line_score_status
          return game_data.dig('status', 'detailedState') unless live?

          outs == 3 ? inning : "#{runners}, #{line_score_outs}, #{inning}"
        end

        def line_score_outs = "#{outs} #{outs == 1 ? 'Out' : 'Outs'}"

        def line_score_innings(flag)
          started? && linescore&.dig('innings') ? team_inning_scores(flag.to_s) : BLANK_LINES
        end

        def team_inning_scores(flag)
          [*linescore['innings'].sort_by { _1['num'] }.map { _1.dig(flag, 'runs') }, *([' '] * 9)].first(innings)
        end

        def innings = [9, linescore['innings'].count].max

        def line_score_team(flag)
          team_rhe = rhe(flag)

          [
            (flag == :home ? home_team : away_team).code,
            *line_score_innings(flag),
            "**#{team_rhe['runs']}**",
            "**#{team_rhe['hits']}**",
            "**#{team_rhe['errors']}**",
            "**#{lob(flag)}**"
          ]
        end

        def line_score_inning_numbers = (1..innings).to_a

        def rhe(flag) = linescore&.dig('teams', flag.to_s, 'runs') ? linescore.dig('teams', flag.to_s) : BLANK_RHE

        def runs(flag) = rhe(flag)['runs']

        # This is surprisingly complicated. I'm going to guess they'll move this info in the next few seasons.
        def lob(flag)
          return '-' unless started?

          batting_info = boxscore.dig('teams', flag.to_s, 'info')&.find { _1['title'] == 'BATTING' }

          return '-' unless batting_info

          lob_info = batting_info['fieldList'].find { _1['label'] == 'Team LOB' }

          lob_info ? lob_info['value'].to_i : 0
        end
      end
    end
  end
end

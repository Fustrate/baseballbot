# frozen_string_literal: true

class Baseballbot
  module Templates
    module GameThreads
      module Components
        class LineScore
          include MarkdownHelpers

          BLANK_RHE = { 'runs' => 0, 'hits' => 0, 'errors' => 0 }.freeze
          BLANK_LINES = ([' '] * 9).freeze

          def initialize(game_thread)
            @game_thread = game_thread
          end

          def to_s
            <<~MARKDOWN.strip
              ### Line Score - #{line_score_status}

              #{table(headers: table_headers, rows: table_rows)}
            MARKDOWN
          end

          protected

          def table_headers = [' ', *[*line_score_inning_numbers, 'R', 'H', 'E', 'LOB'].map { [it, :center] }]

          def table_rows = [line_score_team(:away), line_score_team(:home)]

          def line_score_status
            return @game_thread.game_data.dig('status', 'detailedState') unless @game_thread.live?

            return @game_thread.inning if @game_thread.outs == 3

            "#{@game_thread.runners}, #{line_score_outs}, #{@game_thread.inning}"
          end

          def line_score_outs = "#{@game_thread.outs} #{@game_thread.outs == 1 ? 'Out' : 'Outs'}"

          def line_score_innings(flag)
            return BLANK_LINES unless @game_thread.started? && @game_thread.linescore&.dig('innings')

            team_inning_scores(flag.to_s)
          end

          def team_inning_scores(flag) = [*played_inning_runs(flag), *([' '] * 9)].first(innings)

          def played_inning_runs(flag)
            @game_thread.linescore['innings'].sort_by { it['num'] }.map { it.dig(flag, 'runs') }
          end

          def innings = [9, @game_thread.linescore['innings'].count].max

          def line_score_team(flag)
            team_rhe = rhe(flag)

            [
              (flag == :home ? @game_thread.home_team : @game_thread.away_team).code,
              *line_score_innings(flag),
              "**#{team_rhe['runs']}**",
              "**#{team_rhe['hits']}**",
              "**#{team_rhe['errors']}**",
              "**#{lob(flag)}**"
            ]
          end

          def line_score_inning_numbers = (1..innings).to_a

          def rhe(flag)
            return BLANK_RHE unless @game_thread.linescore&.dig('teams', flag.to_s, 'runs')

            @game_thread.linescore.dig('teams', flag.to_s)
          end

          # This is surprisingly complicated. I'm going to guess they'll move this info in the next few seasons.
          def lob(flag)
            return '-' unless @game_thread.started?

            batting_info = @game_thread.boxscore.dig('teams', flag.to_s, 'info')&.find { it['title'] == 'BATTING' }

            return '-' unless batting_info

            lob_info = batting_info['fieldList'].find { it['label'] == 'Team LOB' }

            lob_info ? lob_info['value'].to_i : 0
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

class Baseballbot
  module Templates
    module GameThreads
      module Components
        class ScoringPlays
          include MarkdownHelpers

          TABLE_HEADERS = [['Inning', :center], 'Event', ['Score', :center]].freeze

          def initialize(game_thread)
            @game_thread = game_thread
          end

          def to_s
            return '' if scoring_plays.none?

            <<~MARKDOWN.strip
              ### Scoring Plays

              #{table(headers: TABLE_HEADERS, rows: table_rows)}
            MARKDOWN
          end

          protected

          def scoring_plays
            @scoring_plays ||= @game_thread.started? && @game_thread.feed.plays ? formatted_plays : []
          end

          def table_rows = scoring_plays.map { ["#{_1[:side]}#{_1[:inning]}", _1[:event], event_score(_1)] }

          def formatted_plays = @game_thread.feed.plays['allPlays'].values_at(*scoring_play_ids).map { format_play(_1) }

          def scoring_play_ids = @game_thread.feed.plays['scoringPlays']

          def format_play(play)
            {
              side: play['about']['halfInning'] == 'top' ? 'T' : 'B',
              team: play['about']['halfInning'] == 'top' ? @game_thread.opponent : @game_thread.team,
              inning: play['about']['inning'],
              event: play['result']['description'],
              score: [play['result']['homeScore'], play['result']['awayScore']]
            }
          end

          def event_score(play)
            return "#{play[:score][0]}-**#{play[:score][1]}**" if play[:side] == 'T'

            "**#{play[:score][0]}**-#{play[:score][1]}"
          end
        end
      end
    end
  end
end

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

          def table_rows = scoring_plays.map { ["#{it[:side]}#{it[:inning]}", it[:event], event_score(it)] }

          def formatted_plays = @game_thread.feed.plays['allPlays'].values_at(*scoring_play_ids).map { format_play(it) }

          def scoring_play_ids = @game_thread.feed.plays['scoringPlays']

          def format_play(play)
            about = play['about']
            modal_link = "https://www.mlb.com/gameday/#{@game_thread.game_pk}/play/#{about['atBatIndex']}"

            {
              side: about['halfInning'] == 'top' ? 'T' : 'B',
              team: about['halfInning'] == 'top' ? @game_thread.opponent : @game_thread.team,
              inning: about['inning'],
              event: "[#{play['result']['description']}](#{modal_link})",
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

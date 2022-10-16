# frozen_string_literal: true

class Baseballbot
  module Template
    class GameThread
      module ScoringPlays
        def scoring_plays_section
          return unless final? && scoring_plays.any?

          <<~MARKDOWN
            ### Scoring Plays

            #{scoring_plays_table}
          MARKDOWN
        end

        def scoring_plays_table
          table(
            headers: [['Inning', :center], 'Event', ['Score', :center]],
            rows: scoring_plays.map { ["#{_1[:side]}#{_1[:inning]}", _1[:event], event_score(_1)] }
          )
        end

        protected

        def scoring_plays
          @scoring_plays ||= started? && feed.plays ? formatted_plays : []
        end

        def formatted_plays = feed.plays['allPlays'].values_at(*feed.plays['scoringPlays']).map { format_play(_1) }

        def format_play(play)
          {
            side: play['about']['halfInning'] == 'top' ? 'T' : 'B',
            team: play['about']['halfInning'] == 'top' ? opponent : team,
            inning: play['about']['inning'],
            event: play['result']['description'],
            score: [play['result']['homeScore'], play['result']['awayScore']]
          }
        end

        def event_score(play)
          return "#{play[:score][0]}-#{bold play[:score][1]}" if play[:side] == 'T'

          "#{bold play[:score][0]}-#{play[:score][1]}"
        end
      end
    end
  end
end

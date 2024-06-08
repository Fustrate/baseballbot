# frozen_string_literal: true

class Baseballbot
  module Templates
    module GameThreads
      module Components
        class ProbableStarters
          include MarkdownHelpers

          TBA = ['TBA', '', '', '', '', '', '', '', ''].freeze

          HEADERS = [
            'Team',
            'Pitcher',
            ['Record', :center],
            ['ERA', :center],
            ['IP', :center],
            ['H', :center],
            ['ER', :center],
            ['BB', :center],
            ['SO', :center],
            ['WHIP', :center]
          ].freeze

          def initialize(game_thread)
            @game_thread = game_thread
          end

          def to_s
            table headers: HEADERS, rows: [
              [team_link(@game_thread.away_team), *probable_starter_line('away')],
              [team_link(@game_thread.home_team), *probable_starter_line('home')]
            ]
          end

          protected

          def team_link(team) = "[#{team.name}](/r/#{@game_thread.subreddit.code_to_subreddit_name(team.code)})"

          def probable_starter_line(flag)
            pitcher_id = @game_thread.game_data.dig('probablePitchers', flag, 'id')

            return TBA unless pitcher_id

            pitcher_line(@game_thread.boxscore.dig('teams', flag, 'players', "ID#{pitcher_id}"))
          end

          def pitcher_line(pitcher)
            return TBA unless pitcher

            season_stats = pitcher.dig('seasonStats', 'pitching')

            [
              "[#{pitcher.dig('person', 'fullName')}](#{player_url(pitcher.dig('person', 'id'))})",
              "#{season_stats['wins']}-#{season_stats['losses']}",
              *season_stats.values_at(
                'era', 'inningsPitched', 'hits', 'earnedRuns', 'baseOnBalls', 'strikeOuts', 'whip'
              )
            ]
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

class Baseballbot
  module Templates
    module GameThreads
      class PitchersTable
        include MarkdownHelpers

        PITCHER_COLUMNS = {
          ip: ->(_, game) { game['inningsPitched'] },
          h: ->(_, game) { game['hits'] },
          r: ->(_, game) { game['runs'] },
          er: ->(_, game) { game['earnedRuns'] },
          bb: ->(_, game) { game['baseOnBalls'] },
          so: ->(_, game) { game['strikeOuts'] },
          'p-s': ->(_, game) { "#{game['pitchesThrown']}-#{game['strikes']}" },
          era: ->(pitcher, _) { pitcher['seasonStats']['pitching']['era'] }
        }.freeze

        attr_reader :template

        def initialize(template, team, stats: %i[ip h r er bb so p-s era])
          @template = template
          @team = team
          @stats = stats
        end

        def to_s
          return unless template.started? && template.boxscore && pitchers.any?

          table(headers: table_header, rows: pitchers.map { pitcher_row(_1) })
        end

        protected

        def pitchers
          @pitchers ||= begin
            team_info = template.boxscore['teams'].find { |_, v| v.dig('team', 'id') == @team.id }[1]

            team_info['pitchers'].map { team_info.dig('players', "ID#{_1}") }
          end
        end

        def table_header = ["**#{@team.code}**", *(@stats.map { [_1.to_s.upcase, :center] })]

        def pitcher_row(pitcher)
          today = game_stats(pitcher)['pitching']

          [player_link(pitcher, title: 'Game Score: ???'), *(@stats.map { PITCHER_COLUMNS[_1].call(pitcher, today) })]
        end

        def pitcher_line(pitcher)
          return 'TBA' unless pitcher

          format '[%<name>s](%<url>s) (%<wins>d-%<losses>d, %<era>s ERA)',
                 name: pitcher.dig('person', 'fullName'),
                 url: player_url(pitcher.dig('person', 'id')),
                 wins: pitcher.dig('seasonStats', 'pitching', 'wins').to_i,
                 losses: pitcher.dig('seasonStats', 'pitching', 'losses').to_i,
                 era: pitcher.dig('seasonStats', 'pitching', 'era')
        end

        def game_stats(player) = (player['gameStats'] || player['stats'] || {})
      end
    end
  end
end

# frozen_string_literal: true

class Baseballbot
  module Templates
    module Sidebars
      module Components
        class DivisionStandings < Standings
          include MarkdownHelpers
          include Enumerable

          def each(&)
            teams_in_division(@subreddit.team.division_id).each(&)
          end

          # TODO
          # def table(**options) = Table.new(teams_in_division(@subreddit.team.division_id), **options).to_s

          protected

          def teams_in_division(division_id) = @all_teams.select { _1.team.dig('division', 'id') == division_id }

          # class Table
          #   def initialize(teams, **options)
          #     @teams = teams
          #     @options = options
          #   end

          #   def to_s
          #   end

          #   protected

          #   def standings_rows
          #     map do |team|
          #       [
          #         "[#{team.name}](/r/#{@subreddit.code_to_subreddit_name(team.abbreviation)})",
          #         team.wins,
          #         team.losses,
          #         team.percent,
          #         team.games_back,
          #         team.last_ten
          #       ]
          #     end
          #   end
          # end
        end
      end
    end
  end
end

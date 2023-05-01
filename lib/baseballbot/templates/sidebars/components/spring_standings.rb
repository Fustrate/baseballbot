# frozen_string_literal: true

class Baseballbot
  module Templates
    module Sidebars
      module Components
        class SpringStandings < Templates::Components::Standings
          include MarkdownHelpers
          include Enumerable
          include Mustache::Enumerable

          def initialize(subreddit, league: nil)
            super(subreddit)

            @spring_id = league ? MLBStatsAPI::Leagues::LEAGUES[league] : @subreddit.team.dig('springLeague', 'id')
          end

          def each(&) = teams_in_league.each(&)

          # TODO
          # def table(**options) = Table.new(teams_in_division(@subreddit.team.division_id), **options).to_s

          protected

          def teams_in_league = @all_teams.select { _1.team.dig('springLeague', 'id') == @spring_id }

          def standings_data
            @subreddit.bot.api.load('spring_standings_hydrate_team', expires: 300) do
              @subreddit.bot.api.standings(standingsTypes: :springTraining, season: @subreddit.today.year)
            end
          end

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

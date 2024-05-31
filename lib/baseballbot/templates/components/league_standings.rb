# frozen_string_literal: true

class Baseballbot
  module Templates
    module Components
      # This is used by the /r/baseball sidebar. Team subs should be showing division standings instead.
      class LeagueStandings < Standings
        def to_s
          <<~MARKDOWN.strip
            # #{@subreddit.today.year} Standings

            Click a team's logo to visit their subreddit

            ## National League

            #{league_table('National League')}

            ## American League

            #{league_table('American League')}
          MARKDOWN
        end

        protected

        def league_table(name)
          LeagueStandingsTable.new(@subreddit, @all_teams.select { _1.team.dig('league', 'name') == name })
        end

        class LeagueStandingsTable
          include MarkdownHelpers

          # I guess I should make this a constant so that I can easily mark 75 wildcard teams when they allow everyone
          # and their grandmother into the playoffs...
          WILDCARDS = 3

          def initialize(subreddit, teams)
            @subreddit = subreddit
            @teams = teams

            mark_league_wildcards
          end

          # I like them positioned like a map because it makes sense. East coast bias can suck it!
          def to_s
            rows = %w[West Central East].map do |division|
              @teams.select { _1.team.dig('division', 'name')[division] }
                .map { "#{team_link(_1)} [#{team_record(_1)}](/r/#{subreddit_name(_1)})" }
            end.transpose

            table(headers: [['West', :center], ['Central', :center], ['East', :center]], rows:)
          end

          protected

          def team_cell(team) = "#{team_link(team)} #{team_record(team)}"

          def team_link(team)
            return "[#{team.abbreviation}][#{team.abbreviation}]" unless team.wildcard_position

            "[#{team.abbreviation}](/r/#{subreddit_name(team)} \"WC#{team.wildcard_position}\")"
          end

          # We have to use a direct link instead of [][ABBR] because those links have #flair
          def team_record(team)
            return "**#{team.wins}-#{team.losses}**" if team.division_champ?

            return "*#{team.wins}-#{team.losses}*" if team.wildcard_champ?

            "#{team.wins}-#{team.losses}"
          end

          def subreddit_name(team) = @subreddit.code_to_subreddit_name(team.abbreviation)

          # @!group Wildcards

          def mark_league_wildcards
            teams_in_playoffs = 3 + WILDCARDS

            division_leaders = @teams.count(&:division_leader?)

            spots_remaining = teams_in_playoffs - division_leaders

            return unless spots_remaining.positive?

            ranked = ranked_wildcard_teams

            while spots_remaining.positive?
              wildcards_used = WILDCARDS - spots_remaining

              spots_remaining -= mark_wildcards(ranked[wildcards_used], wildcards_used + 1)
            end
          end

          def ranked_wildcard_teams = @teams.reject(&:division_leader?).sort_by(&:wildcard_rank)

          # wildcard_rank is different for two teams in the same position
          def mark_wildcards(target, position)
            @teams
              .select { !_1.division_leader? && _1.league_games_back == target.league_games_back }
              .each { _1.wildcard_position = position }
              .count
          end

          # @!endgroup Wildcards
        end
      end
    end
  end
end

# frozen_string_literal: true

class Baseballbot
  module Template
    class Shared
      module Standings
        def all_teams
          return @all_teams if @all_teams

          load_all_teams_standings

          %i[al nl].each { |league| mark_league_wildcards(league) }

          @all_teams
        end

        def standings
          teams_in_division(@subreddit.team.division_id)
        end

        def full_standings
          @full_standings ||= {
            al: teams_in_division(:al_west).zip(
              teams_in_division(:al_central),
              teams_in_division(:al_east)
            ),
            nl: teams_in_division(:nl_west).zip(
              teams_in_division(:nl_central),
              teams_in_division(:nl_east)
            )
          }
        end
        alias leagues full_standings

        def draft_order
          @draft_order ||= all_teams
            .sort_by! { |team| team[:sort_order] }
            .reverse
        end

        def teams_in_league(league)
          league_id = if league.is_a?(Integer)
                        league
                      else
                        MLBStatsAPI::Leagues::LEAGUES[league]
                      end

          all_teams.select do |team|
            team.dig(:team, 'league', 'id') == league_id
          end
        end

        def teams_in_division(division)
          division_id = if division.is_a?(Integer)
                          division
                        else
                          MLBStatsAPI::Divisions::DIVISIONS[division]
                        end

          all_teams.select do |team|
            team.dig(:team, 'division', 'id') == division_id
          end
        end

        def wildcards_in_league(league)
          teams_in_league(league)
            .reject { |team| team[:games_back] == '-' }
            .sort_by! { |team| team[:wildcard_gb].to_i }
        end

        # The API returns an empty set if Spring Training hasn't started yet
        def team_stats
          @team_stats ||= all_teams.find { |team| team[:team]['id'] == @subreddit.team.id } || {}
        end

        protected

        # @!group Wildcards

        # Take the eligible teams, remove all teams who aren't at least tied
        # with the team in 5th place, remove teams in first place, and then
        # split between teams ahead of the second spot
        #
        # This might put two teams tied for second instead of tied for first
        def mark_league_wildcards(league)
          teams = teams_in_league(league)

          division_leaders = teams.count { |team| team[:division_lead] }

          # 5 or more division leaders means no wildcards
          return if division_leaders >= 5

          allowed_wildcards = 5 - division_leaders

          ranked = ranked_wildcard_teams(teams)

          teams_in_first_wc = mark_wildcards teams, ranked[0], 1

          return unless teams_in_first_wc < allowed_wildcards

          mark_wildcards teams, ranked[1], 2
        end

        def ranked_wildcard_teams(teams)
          teams
            .reject { |team| team[:division_lead] }
            .sort_by { |team| team[:wildcard_rank] }
        end

        def mark_wildcards(teams, target, position)
          teams
            .select { |team| team[:wildcard_rank] == target[:wildcard_rank] }
            .each { |team| team[:wildcard_position] = position }
            .count
        end

        # @!endgroup Wildcards

        def load_all_teams_standings
          data = @bot.api.load('standings_hydrate_team', expires: 300) do
            @bot.api.standings(leagues: %i[al nl], season: Date.today.year)
          end

          @all_teams = data['records'].flat_map do |division|
            division['teamRecords'].map { |team| generate_standings_row(team) }
          end

          @all_teams.sort_by! { |team| team[:sort_order] }
        end

        def generate_standings_row(row)
          TeamStandingsData.call(row).merge subreddit: subreddit(row['team']['abbreviation'])
        end
      end
    end
  end
end

module TeamStandingsData
  class << self
    def call(row)
      {
        team: row['team'],
        **standard_information(row),
        **team_records(row),
        **division_stats(row),
        **wildcard_standings(row)
      }.tap do |info|
        # Used for sorting teams in the standings. Lowest losing %, most
        # wins, least losses, and then fall back to three letter code
        info[:sort_order] = sort_order(info)
      end
    end

    def standard_information(row)
      {
        losses: row['losses'],
        percent: row['leagueRecord']['pct'].to_f,
        run_diff: row['runDifferential'],
        streak: row.dig('streak', 'streakCode') || '-',
        wins: row['wins']
      }
    end

    def division_stats(row)
      {
        division_champ: row['divisionChamp'],
        division_lead: row['divisionLeader'],
        elim: row['eliminationNumber'],
        games_back: row['divisionGamesBack']
      }
    end

    def team_records(row)
      records = row.dig('records', 'splitRecords')
        .map { |rec| [rec['type'], [rec['wins'], rec['losses']]] }
        .to_h

      {
        home_record: records['home'],
        last_ten: records['lastTen'],
        road_record: records['away']
      }
    end

    def wildcard_standings(row)
      {
        elim_wildcard: row['wildCardEliminationNumber'].to_i,
        wildcard_champ: false,
        wildcard_gb: row['wildCardGamesBack'],
        wildcard_rank: row['wildCardRank'].to_i,
        wildcard: row['hasWildcard'] && !row['divisionLeader']
      }
    end

    def sort_order(row)
      [
        1.0 - row[:percent],
        162 - row[:wins],
        row[:losses],
        row[:team]['abbreviation']
      ]
    end
  end
end

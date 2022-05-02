# frozen_string_literal: true

class Baseballbot
  module Template
    class Shared
      module Standings
        # I guess I should make this a constant so that I can easily mark 75 wildcard teams when they allow everyone and
        # their grandmother into the playoffs...
        WILDCARDS = 3

        def all_teams
          return @all_teams if @all_teams

          load_all_teams_standings

          %i[al nl].each { mark_league_wildcards(_1) }

          @all_teams
        end

        def standings = teams_in_division(@subreddit.team.division_id)

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
            .sort_by! { _1[:sort_order] }
            .reverse
        end

        def teams_in_league(league)
          league_id = league.is_a?(Integer) ? league : MLBStatsAPI::Leagues::LEAGUES[league]

          all_teams.select { _1.dig(:team, 'league', 'id') == league_id }
        end

        def teams_in_division(division)
          division_id = division.is_a?(Integer) ? division : MLBStatsAPI::Divisions::DIVISIONS[division]

          all_teams.select { _1.dig(:team, 'division', 'id') == division_id }
        end

        def wildcards_in_league(league)
          teams_in_league(league)
            .reject { _1[:games_back] == '-' }
            .sort_by! { _1[:wildcard_gb].to_i }
        end

        # The API returns an empty set if Spring Training hasn't started yet
        def team_stats
          @team_stats ||= all_teams.find { _1[:team]['id'] == @subreddit.team.id } || {}
        end

        protected

        # @!group Wildcards

        # This might put two teams tied for second instead of tied for first
        def mark_league_wildcards(league)
          teams_in_playoffs = 3 + WILDCARDS

          teams = teams_in_league(league)

          division_leaders = teams.count { _1[:division_lead] }

          spots_remaining = teams_in_playoffs - division_leaders

          return unless spots_remaining.positive?

          ranked = ranked_wildcard_teams(teams)

          while spots_remaining.positive?
            wildcards_used = WILDCARDS - spots_remaining

            spots_remaining -= mark_wildcards(teams, ranked[wildcards_used], wildcards_used + 1)
          end
        end

        def ranked_wildcard_teams(teams)
          teams
            .reject { _1[:division_lead] }
            .sort_by { _1[:wildcard_rank] }
        end

        # wildcard_rank is different for two teams in the same position
        def mark_wildcards(teams, target, position)
          teams
            .select { !_1[:division_lead] && _1[:league_games_back] == target[:league_games_back] }
            .each { _1[:wildcard_position] = position }
            .count
        end

        # @!endgroup Wildcards

        def load_all_teams_standings
          data = @bot.api.load('standings_hydrate_team', expires: 300) do
            @bot.api.standings(leagues: %i[al nl], season: Date.today.year)
          end

          @all_teams = data['records'].flat_map do |division|
            division['teamRecords'].map { generate_standings_row(_1) }
          end

          @all_teams.sort_by! { _1[:sort_order] }
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
        # Used for sorting teams in the standings. Lowest losing %, most wins, least losses, and then fall back to three
        # letter code
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
        games_back: row['divisionGamesBack'],
        league_games_back: row['leagueGamesBack']
      }
    end

    def team_records(row)
      records = row.dig('records', 'splitRecords').to_h { [_1['type'], [_1['wins'], _1['losses']]] }

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

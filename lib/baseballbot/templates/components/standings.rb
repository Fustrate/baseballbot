# frozen_string_literal: true

class Baseballbot
  module Templates
    module Components
      class Standings
        include MarkdownHelpers

        def initialize(subreddit)
          @subreddit = subreddit

          load_standings_data
        end

        # The API returns an empty set if Spring Training hasn't started yet. This is used by the BOS & NYM sidebars.
        def team_stats
          @team_stats ||= @all_teams.find { it.team['id'] == @subreddit.team.id } || {}
        end

        def in_draft_order
          @in_draft_order ||= @all_teams.sort_by(&:sort_order).reverse
        end

        protected

        def load_standings_data
          @all_teams = standings_data['records'].flat_map do |division|
            division['teamRecords'].map { StandingsTeam.new(it, @subreddit) }
          end

          @all_teams.sort_by!(&:sort_order)
        end

        def standings_data
          @subreddit.bot.api.load('standings_hydrate_team', expires: 300) do
            @subreddit.bot.api.standings(leagues: %i[al nl], season: @subreddit.today.year)
          end
        end
      end

      class StandingsTeam
        # This is based off of other teams' data as well, so it can't be calculated inside this class.
        attr_accessor :wildcard_position

        attr_reader :subreddit, :current

        def initialize(row, subreddit)
          @row = row

          @subreddit = subreddit.code_to_subreddit_name(@row.dig('team', 'abbreviation'))
          @current = @row.dig('team', 'abbreviation') == subreddit.code
        end

        def team = @row['team']

        def name = @row.dig('team', 'teamName')

        def full_name = @row.dig('team', 'name')

        def abbreviation = @row.dig('team', 'abbreviation')

        def wins = @row['wins']

        def losses = @row['losses']

        def run_diff = @row['runDifferential']

        def percent = format('%0.3<percent>f', percent: @row['leagueRecord']['pct'].to_f).sub(/\A0+/, '')

        def streak = @row.dig('streak', 'streakCode') || '-'

        def division_champ? = @row['divisionChamp']

        def division_leader? = @row['divisionLeader']

        def division_rank = @row['divisionRank']

        def elim = @row['eliminationNumber']

        def games_back = @row['divisionGamesBack'].gsub(/\.0$/, '')

        def league_games_back = @row['leagueGamesBack'].gsub(/\.0$/, '')

        def home_record = records['home']&.join('-') || '0-0'

        def home_wins = records.dig('home', 0) || 0

        def home_losses = records.dig('home', 1) || 0

        def last_ten = records['lastTen']&.join('-') || '0-0'

        def road_record = records['away']&.join('-') || '0-0'

        def road_wins = records.dig('away', 0) || 0

        def road_losses = records.dig('away', 1) || 0

        def elim_wildcard = row['wildCardEliminationNumber'].to_i

        def wildcard_champ? = false

        def wildcard_gb = @row['wildCardGamesBack']

        def wildcard_rank = @row['wildCardRank'].to_i

        def wildcard? = @row['hasWildcard'] && !division_leader?

        # MLB seems to use the following order: Lowest losing %, most wins, least losses, and then fall back to three
        # letter code
        def sort_order
          @sort_order ||= [
            1.0 - @row['leagueRecord']['pct'].to_f,
            162 - wins,
            losses,
            @row['divisionRank'].to_i,
            abbreviation
          ]
        end

        protected

        def records
          @records ||= @row.dig('records', 'splitRecords').to_h { [it['type'], [it['wins'], it['losses']]] }
        end
      end
    end
  end
end

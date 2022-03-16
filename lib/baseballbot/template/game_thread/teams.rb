# frozen_string_literal: true

class Baseballbot
  module Template
    class GameThread
      module Teams
        def away_record = standings_by_team_id[game_data.dig('teams', 'away', 'id')] || '0-0'

        def home_record = standings_by_team_id[game_data.dig('teams', 'home', 'id')] || '0-0'

        # The game endpoint is returning stale data, so let's try grabbing them from the standings
        # endpoint instead.
        def standings_by_team_id
          @standings_by_team_id ||= @bot.api
            .standings(leagues: %i[al nl], season: Date.today.year)['records']
            .flat_map do |division|
              division['teamRecords'].map { [_1.dig('team', 'id'), _1.values_at('wins', 'losses').join('-')] }
            end
            .to_h
        end

        def home_team
          @home_team ||= @bot.api.team game_data.dig('teams', 'home', 'id')
        end

        def away_team
          @away_team ||= @bot.api.team game_data.dig('teams', 'away', 'id')
        end

        def opponent = @subreddit.team&.id == away_team.id ? home_team : away_team

        def team = @subreddit.team || home_team

        def home? = @subreddit.team ? home_team.id == @subreddit.team.id : true

        def won? = (home? == (home_rhe['runs'] > away_rhe['runs']) if final?)

        def lost? = (home? == (home_rhe['runs'] < away_rhe['runs']) if final?)
      end
    end
  end
end

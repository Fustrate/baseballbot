# frozen_string_literal: true

class Baseballbot
  module Templates
    module GameThreads
      module Teams
        def away_record = standings_by_team_id[game_data.dig('teams', 'away', 'id')] || '0-0'

        def home_record = standings_by_team_id[game_data.dig('teams', 'home', 'id')] || '0-0'

        def home_team
          @home_team ||= @subreddit.bot.api.team game_data.dig('teams', 'home', 'id')
        end

        def away_team
          @away_team ||= @subreddit.bot.api.team game_data.dig('teams', 'away', 'id')
        end

        def opponent = @subreddit.team&.id == away_team.id ? home_team : away_team

        # TODO: What about when a sub adds a game thread for a rival's playoff game?
        def team = @subreddit.team || home_team

        def home? = @subreddit.team ? home_team.id == @subreddit.team.id : true

        def won?
          (home? == (linescore.dig('teams', 'home', 'runs') > linescore.dig('teams', 'away', 'runs')) if final?)
        end

        def lost?
          (home? == (linescore.dig('teams', 'home', 'runs') < linescore.dig('teams', 'away', 'runs')) if final?)
        end

        def home_subreddit = @subreddit.code_to_subreddit_name(home_team.code)

        def away_subreddit = @subreddit.code_to_subreddit_name(away_team.code)

        protected

        # The game endpoint is returning stale data, so let's try grabbing them from the standings endpoint instead.
        def standings_by_team_id
          @standings_by_team_id ||= @subreddit.bot.api
            .standings(leagues: %i[al nl], season: @subreddit.today.year)['records']
            .flat_map do |division|
              division['teamRecords'].map { [_1.dig('team', 'id'), _1.values_at('wins', 'losses').join('-')] }
            end
            .to_h
        end
      end
    end
  end
end

# frozen_string_literal: true

class Baseballbot
  module Templates
    module GameThreads
      class Title < Templates::Title
        # Mustache uses the @template variable so we'll call it @game_thread
        def initialize(title, game_thread:)
          super(title, date: game_thread.start_time_local)

          @game_thread = game_thread
        end

        def start_time_et = @game_thread.start_time_et.strftime('%-I:%M %p ET')

        def opponent_name = @game_thread.opponent.name

        def game_number
          @game_thread.game_data.dig('teams', @game_thread.home? ? 'home' : 'away', 'record', 'gamesPlayed') + 1
        end

        def away_full_name = @game_thread.away_team.full_name

        def away_name = @game_thread.away_team.name

        def away_pitcher = probable_starter_name('away')

        def away_record = @game_thread.away_record

        def home_full_name = @game_thread.home_team.full_name

        def home_name = @game_thread.home_team.name

        def home_pitcher = probable_starter_name('home')

        def home_record = @game_thread.home_record

        def away_runs = @game_thread.linescore&.dig('teams', 'away', 'runs') || 0

        def home_runs = @game_thread.linescore&.dig('teams', 'home', 'runs') || 0

        def series_game = postseason_data.dig('seriesStatus', 'shortDescription')

        def home_wins = postseason_data.dig('teams', 'home', 'leagueRecord', 'wins')

        def away_wins = postseason_data.dig('teams', 'away', 'leagueRecord', 'wins')

        def pitcher_names = no_hitter_pitchers.join(', ')

        def pitching_team = (no_hitter_flag == 'home' ? @game_thread.home_team : @game_thread.away_team).name

        def batting_team = (no_hitter_flag == 'home' ? @game_thread.away_team : @game_thread.home_team).name

        protected

        def postseason_data
          # seriesStatus is not included in the live feed
          @postseason_data ||= @game_thread.subreddit.bot.api
            .schedule(gamePk: @game_thread.game_pk, hydrate: 'seriesStatus')
            .dig('dates', 0, 'games', 0)
        end

        def probable_starter_name(flag)
          pitcher_id = @game_thread.game_data.dig('probablePitchers', flag, 'id')

          pitcher_id ? player_name(@game_thread.boxscore.dig('teams', flag, 'players', "ID#{pitcher_id}")) : 'TBA'
        end

        def player_name(player)
          return 'TBA' unless player

          player['boxscoreName'] ||
            player.dig('name', 'boxscore') ||
            @game_thread.game_data.dig('players', "ID#{player['person']['id']}", 'boxscoreName')
        end

        def no_hitter_flag = (@game_thread.flag if @game_thread.is_a?(Templates::NoHitter))

        def no_hitter_pitchers
          no_hitter_team = @game_thread.boxscore.dig('teams', no_hitter_flag)

          no_hitter_team['pitchers'].map { player_name(no_hitter_team.dig('players', "ID#{_1}")) }
        end
      end
    end
  end
end

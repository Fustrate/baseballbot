# frozen_string_literal: true

require 'mustache'

class Baseballbot
  module Templates
    module GameThreads
      class Title < Mustache
        def initialize(template, title)
          super()

          self.template = title

          # Mustache uses the @template variable
          @game_thread = template
        end

        def to_s
          @to_s ||= begin
            title = @game_thread.start_time_local.strftime(render)

            title
          end
        end

        def year = @game_thread.start_time_local.year

        def month = @game_thread.start_time_local.month

        def day = @game_thread.start_time_local.day

        def month_name = @game_thread.start_time_local.strftime('%B')

        def short_month = @game_thread.start_time_local.strftime('%b')

        def day_of_week = @game_thread.start_time_local.strftime('%A')

        def short_day_of_week = @game_thread.start_time_local.strftime('%a')

        def short_year = @game_thread.start_time_local.strftime('%y')

        def start_time = @game_thread.start_time_local.strftime('%-I:%M %p')

        def start_time_et = @game_thread.start_time_et.strftime('%-I:%M %p ET')

        def opponent_name = @game_thread.opponent.name

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

        def pitcher_names = no_hitter_pitchers.map { player_name(_1) }.join(', ')

        def pitching_team = no_hitter_flag == 'home' ? home_team.name : away_team.name

        def batting_team = no_hitter_flag == 'home' ? away_team.name : home_team.name

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

        def no_hitter_flag = @game_thread.flag if @game_thread.is_a?(Templates::NoHitter)

        def no_hitter_pitchers = no_hitter_flag == 'home' ? home_pitchers : away_pitchers
      end
    end
  end
end
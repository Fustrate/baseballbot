# frozen_string_literal: true

class Baseballbot
  module Templates
    module GameThreads
      module Titles
        def formatted_title
          @formatted_title ||= begin
            title = start_time_local.strftime(@title || default_title)

            # Don't waste time formatting if there are no interpolations
            title = format(title, title_interpolations) if title.match?(/%[{<]/)

            title
          end
        end

        protected

        def title_interpolations
          {
            start_time: start_time_local.strftime('%-I:%M %p'),
            start_time_et: start_time_et.strftime('%-I:%M %p ET'),
            **team_interpolations,
            **postseason_interpolations,
            **postgame_interpolations
          }
        end

        def team_interpolations
          {
            opponent_name: opponent.name,
            **away_interpolations,
            **home_interpolations
          }
        end

        def away_interpolations
          {
            away_full_name: away_team.full_name,
            away_name: away_team.name,
            away_pitcher: probable_starter_name('away'),
            away_record:
          }
        end

        def home_interpolations
          {
            home_full_name: home_team.full_name,
            home_name: home_team.name,
            home_pitcher: probable_starter_name('home'),
            home_record:
          }
        end

        def postgame_interpolations
          {
            away_runs: linescore&.dig('teams', 'away', 'runs') || 0,
            home_runs: linescore&.dig('teams', 'home', 'runs') || 0
          }
        end

        def postseason_interpolations
          # seriesStatus is not included in the live feed
          series_data = @subreddit.bot.api
            .schedule(gamePk: @game_pk, hydrate: 'seriesStatus')
            .dig('dates', 0, 'games', 0)

          {
            series_game: series_data.dig('seriesStatus', 'shortDescription'),
            home_wins: series_data.dig('teams', 'home', 'leagueRecord', 'wins'),
            away_wins: series_data.dig('teams', 'away', 'leagueRecord', 'wins')
          }
        end

        def default_title
          titles = @subreddit.options.dig('game_threads', 'title')

          return titles if titles.is_a?(String)

          playoffs = %w[F D L W].include? game_data.dig('game', 'type')

          titles[playoffs ? 'postseason' : 'default'] || titles.values.first
        end

        def probable_starter_name(flag)
          pitcher_id = game_data.dig('probablePitchers', flag, 'id')

          player_name(boxscore.dig('teams', flag, 'players', "ID#{pitcher_id}")) if pitcher_id
        end

        def runs_scored(flag) = (linescore&.dig('teams', flag, 'runs') || 0)
      end
    end
  end
end

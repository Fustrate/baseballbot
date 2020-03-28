# frozen_string_literal: true

class Baseballbot
  module Template
    class GameThread
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
            away_full_name: away_team.full_name,
            away_name: away_team.name,
            away_pitcher: player_name(probable_away_starter),
            away_record: away_record,
            home_full_name: home_team.full_name,
            home_name: home_team.name,
            home_pitcher: player_name(probable_home_starter),
            home_record: home_record
          }
        end

        def postgame_interpolations
          {
            away_runs: away_rhe['runs'],
            home_runs: home_rhe['runs']
          }
        end

        def postseason_interpolations
          # seriesStatus is not included in the live feed
          psdata = @bot.api.schedule(gamePk: @game_pk, hydrate: 'seriesStatus')
            .dig('dates', 0, 'games', 0)

          {
            series_game: psdata.dig('seriesStatus', 'shortDescription'),
            home_wins: psdata.dig('teams', 'home', 'leagueRecord', 'wins'),
            away_wins: psdata.dig('teams', 'away', 'leagueRecord', 'wins')
          }
        end

        def default_title
          titles = @subreddit.options.dig('game_threads', 'title')

          return titles if titles.is_a?(String)

          playoffs = %w[F D L W].include? game_data.dig('game', 'type')

          titles[playoffs ? 'postseason' : 'default'] || titles.values.first
        end
      end
    end
  end
end

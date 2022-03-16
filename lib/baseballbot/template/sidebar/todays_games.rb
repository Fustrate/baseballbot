# frozen_string_literal: true

class Baseballbot
  module Template
    class Sidebar
      module TodaysGames
        TODAYS_GAMES_HYDRATE = 'game(content(summary)),linescore,flags,team'

        def todays_games(date)
          @date = date || @subreddit.now

          load_known_game_threads

          scheduled_games.map { process_todays_game(_1) }
        end

        protected

        def scheduled_games
          @bot.api.schedule(sportId: 1, date: @date.strftime('%m/%d/%Y'), hydrate: TODAYS_GAMES_HYDRATE)
            .dig('dates', 0, 'games') || []
        end

        def process_todays_game(game) = game_hash(game).tap { mark_winner_and_loser(_1) }

        def game_hash(game)
          status = game.dig('status', 'abstractGameState')

          started = !MLBStatsAPI::Games.pregame_status?(status)

          {
            home: team_data(game, 'home', started),
            away: team_data(game, 'away', started),
            raw_status: status,
            status: gameday_link(game_status(game), game['gamePk']),
            free: game.dig('content', 'media', 'freeGame')
          }
        end

        def team_data(game, flag, started)
          team = game.dig('teams', flag)

          {
            team: link_for_team(game:, team:),
            score: (started && team['score'] ? team['score'].to_i : '')
          }
        end

        def mark_winner_and_loser(data)
          return unless scores_differ?(data)

          winner, loser = winner_loser_flags(data)

          data[winner][:score] = bold data[winner][:score]
          data[loser][:score] = italic data[loser][:score] if MLBStatsAPI::Games.postgame_status?(data[:raw_status])
        end

        def scores_differ?(data)
          !MLBStatsAPI::Games.pregame_status?(data[:raw_status]) && data[:home][:score] != data[:away][:score]
        end

        def winner_loser_flags(data) = data[:home][:score] > data[:away][:score] ? %i[home away] : %i[away home]

        def link_for_team(game:, team:)
          abbreviation = team_abbreviation(game, team)

          # This is no longer included in the data - we might have to switch to
          # using game_pk instead.
          gid = [
            @date.strftime('%Y_%m_%d'),
            "#{game.dig('teams', 'away', 'team', 'teamCode')}mlb",
            "#{game.dig('teams', 'home', 'team', 'teamCode')}mlb",
            game['gameNumber']
          ].join('_')

          post_id = @game_threads["#{gid}_#{subreddit(abbreviation)}".downcase]

          return "[^★](/#{post_id} \"team-#{abbreviation.downcase}\")" if post_id

          "[][#{abbreviation}]"
        end

        def team_abbreviation(game, team)
          return team.dig('team', 'abbreviation') unless team.dig('team', 'name') == 'Intrasquad'

          game.dig('teams', 'home', 'team', 'abbreviation')
        end

        def game_status(game)
          status = game.dig('status', 'detailedState')

          case status
          when 'In Progress'   then game_inning game
          when 'Postponed'     then italic 'PPD'
          when 'Delayed Start' then delay_type game
          when 'Delayed'       then "#{delay_type game} #{game_inning game}"
          when 'Warmup'        then 'Warmup'
          else
            pre_or_post_game_status(game, status)
          end
        end

        def pre_or_post_game_status(game, status)
          if MLBStatsAPI::Games.postgame_status?(status)
            innings = game.dig('linescore', 'currentInning')

            return innings == 9 ? 'F' : "F/#{innings}"
          end

          Baseballbot::Utility
            .parse_time(game['gameDate'], in_time_zone: @subreddit.timezone)
            .strftime('%-I:%M')
        end

        def delay_type(game) = game.dig('status', 'reason') == 'Rain' ? '☂' : 'Delay'

        def game_inning(game)
          (game.dig('linescore', 'isTopInning') ? '▲' : '▼') + bold(game.dig('linescore', 'currentInning'))
        end

        def gameday_link(text, game_pk) = link_to(text, url: "https://www.mlb.com/gameday/#{game_pk}")

        def load_known_game_threads
          @game_threads = {}

          @bot.redis.keys(@date.strftime('%Y_%m_%d_*')).each do |key|
            # _, game_pk = key.split('_').last

            @bot.redis.hgetall(key).each do |subreddit, link_id|
              # @game_threads["#{game_pk}_#{subreddit}".downcase] = link_id
              @game_threads["#{key}_#{subreddit}".downcase] = link_id
            end
          end
        end
      end
    end
  end
end

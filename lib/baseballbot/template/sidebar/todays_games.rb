# frozen_string_literal: true

class Baseballbot
  module Template
    class Sidebar
      class TodaysGames
        TODAYS_GAMES_HYDRATE = 'game(content(summary)),linescore,flags,team'

        TODAYS_GAMES_SQL = <<~SQL
          SELECT post_id, game_pk, name
          FROM game_threads
          INNER JOIN subreddits ON (subreddits.id = subreddit_id)
          WHERE starts_at::date = $1
        SQL

        def initialize(subreddit, date = nil)
          @subreddit = subreddit
          @date = date || subreddit.now

          load_known_game_threads
        end

        def generate = scheduled_games.map { process_todays_game(_1) }

        protected

        def scheduled_games
          @subreddit.bot.api.schedule(sportId: 1, date: @date.strftime('%m/%d/%Y'), hydrate: TODAYS_GAMES_HYDRATE)
            .dig('dates', 0, 'games') || []
        end

        def process_todays_game(game) = game_hash(game).tap { mark_winner_and_loser(_1) }

        def game_hash(game)
          raw_status = game.dig('status', 'abstractGameState')

          started = started?(raw_status)

          {
            home: team_data(game, 'home', started),
            away: team_data(game, 'away', started),
            raw_status:,
            status: gameday_link(game_status(game), game['gamePk']),
            free: game.dig('content', 'media', 'freeGame'),
            national: national_status(game)
          }
        end

        # The Apple logo doesn't appear correctly on Windows, so just show the text for everything.
        def national_status(game) = game.dig('content', 'media', 'freeGame') ? 'MLB.tv' : national_feeds(game).first

        def national_feeds(game)
          # Postponed games won't have media
          return [] unless game.dig('content', 'media', 'epg')

          game
            .dig('content', 'media', 'epg')
            .find { _1['title'] == 'MLBTV' }['items']
            .filter_map { _1['callLetters'] if _1['mediaFeedType'] == 'NATIONAL' }
        end

        def team_data(game, flag, started)
          team = game.dig('teams', flag)

          { **team_info(game:, team:), score: (started && team['score'] ? team['score'].to_i : '') }
        end

        def mark_winner_and_loser(data)
          return unless scores_differ?(data)

          winner, loser = winner_loser_flags(data)

          data[winner][:score] = "**#{data[winner][:score]}**"
          data[loser][:score] = "*#{data[loser][:score]}*" if MLBStatsAPI::Games.postgame_status?(data[:raw_status])
        end

        def scores_differ?(data) = started?(data[:raw_status]) && data[:home][:score] != data[:away][:score]

        def started?(status) = !MLBStatsAPI::Games.pregame_status?(status)

        def winner_loser_flags(data) = data[:home][:score] > data[:away][:score] ? %i[home away] : %i[away home]

        def team_info(game:, team:)
          abbreviation = team_abbreviation(game, team)
          team_subreddit = @subreddit.bot.default_subreddit(abbreviation)

          post_id = @game_threads[game['gamePk'].to_i][team_subreddit.downcase]

          {
            link: post_id ? "[^★](/#{post_id} \"team-#{abbreviation.downcase}\")" : "[][#{abbreviation}]",
            post_id:,
            abbreviation:,
            name: team_name(game, team),
            subreddit: team_subreddit
          }
        end

        def team_abbreviation(game, team) = find_team(game, team)['abbreviation']

        def team_name(game, team) = find_team(game, team)['clubName']

        def find_team(game, team) = intrasquad?(team) ? game.dig('teams', 'home', 'team') : team['team']

        def intrasquad?(team) = team.dig('team', 'name') == 'Intrasquad'

        def game_status(game)
          status = game.dig('status', 'detailedState')

          case status
          when 'In Progress'   then game_inning game
          when 'Postponed'     then '*PPD*'
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

          Baseballbot::Utility.parse_time(game['gameDate'], in_time_zone: @subreddit.timezone).strftime('%-I:%M')
        end

        def delay_type(game) = game.dig('status', 'reason') == 'Rain' ? '☂' : 'Delay'

        def game_inning(game)
          "#{game.dig('linescore', 'isTopInning') ? '▲' : '▼'}**#{game.dig('linescore', 'currentInning')}**"
        end

        def gameday_link(text, game_pk) = "[#{text}](https://www.mlb.com/gameday/#{game_pk})"

        def load_known_game_threads
          @game_threads = Hash.new { |h, k| h[k] = {} }

          @subreddit.bot.db.exec_params(TODAYS_GAMES_SQL, [@date.strftime('%F')]).each do |row|
            @game_threads[row['game_pk'].to_i][row['name']] = row['post_id']
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

class Baseballbot
  module Templates
    module Sidebars
      module Components
        class TodaysGames
          include MarkdownHelpers

          TODAYS_GAMES_HYDRATE = 'game(content(summary)),linescore,flags,team'

          TODAYS_GAMES_SQL = <<~SQL
            SELECT post_id, game_pk, name
            FROM game_threads
            INNER JOIN subreddits ON (subreddits.id = subreddit_id)
            WHERE starts_at::date = $1
          SQL

          # This table can also be shown in the daily ATH thread, where [][LAD] links aren't set up.
          def initialize(subreddit, links:, date: nil)
            @subreddit = subreddit

            # Default to 3 hours ago so that late west coast games show for a while after midnight.
            @date = date || (subreddit.now - 10_800)
            @links = links

            load_known_game_threads
          end

          def to_s
            <<~MARKDOWN.strip
              ## #{(@subreddit.now - 10_800).strftime('%A')}'s Games

              #{table(headers: [' ', [' ', :center], [' ', :center]] * 2, rows: game_rows)}

              ^(★)Game Thread. All game times are Eastern.
            MARKDOWN
          end

          def to_a = scheduled_games.map { game_hash(_1) }

          protected

          def game_rows
            to_a
              .each_slice(2)
              .flat_map { |one, two| [[*away_cells(one), *away_cells(two)], [*home_cells(one), *home_cells(two)]] }
          end

          def away_cells(game) = game ? [*game[:away].values_at(:link, :score), game[:status]] : ['', '', '']

          def home_cells(game)
            return ['', '', ''] unless game

            [*game[:home].values_at(:link, :score), game[:national] ? "^(#{game[:national]})" : '']
          end

          def scheduled_games
            @subreddit.bot.api.schedule(sportId: 1, date: @date.strftime('%m/%d/%Y'), hydrate: TODAYS_GAMES_HYDRATE)
              .dig('dates', 0, 'games') || []
          end

          def game_hash(game)
            raw_status = game.dig('status', 'abstractGameState')

            started = started?(raw_status)

            {
              home: team_data(game, 'home', started),
              away: team_data(game, 'away', started),
              raw_status:,
              status: gameday_link(game_status(game), game['gamePk']),
              national: national_status(game)
            }.tap { mark_winner_and_loser(_1) }
          end

          # The Apple logo doesn't appear correctly on Windows, so just show the text for everything.
          def national_status(game) = game.dig('content', 'media', 'freeGame') ? 'MLB.tv' : national_feeds(game).first

          # Postponed games won't have media
          def national_feeds(game)
            (game.dig('content', 'media', 'epg') || [{ 'title' => 'MLBTV', 'items' => [] }])
              .find { _1['title'] == 'MLBTV' }['items']
              .filter_map { _1['callLetters'] if _1['mediaFeedType'] == 'NATIONAL' }
          end

          def team_data(game, flag, started)
            team = game.dig('teams', flag)

            { link: team_link(game:, team:), score: (started && team['score'] ? team['score'].to_i : '') }
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

          def team_link(game:, team:)
            abbreviation = team_abbreviation(game, team)
            team_sub = @subreddit.bot.default_subreddit(abbreviation)

            post_id = @game_threads[game['gamePk'].to_i][team_sub.downcase]

            return "[^★](/#{post_id} \"team-#{abbreviation.downcase}\")" if post_id

            @links == :code ? "[][#{abbreviation}]" : "[](/r/#{team_sub})"
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
            return final_status(game.dig('linescore', 'currentInning')) if MLBStatsAPI::Games.postgame_status?(status)

            Baseballbot::Utility.parse_time(game['gameDate'], in_time_zone: @subreddit.timezone).strftime('%-I:%M')
          end

          def final_status(innings) = (innings == 9 ? 'F' : "F/#{innings}")

          def delay_type(game) = game.dig('status', 'reason') == 'Rain' ? '☂' : 'Delay'

          def game_inning(game) = "#{inning_side(game)}**#{game.dig('linescore', 'currentInning')}**"

          def inning_side(game) = game.dig('linescore', 'isTopInning') ? '▲' : '▼'

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
end

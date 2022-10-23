# frozen_string_literal: true

class Baseballbot
  module Template
    class Sidebar
      module Postseason
        POSTSEASON_SERIES_NAMES = {
          'AL Wild Card Series' => 'AL Wild Card',
          'ALCS' => 'AL Championship Series',
          'ALDS' => 'AL Division Series',
          'NL Wild Card Series' => 'NL Wild Card',
          'NLCS' => 'NL Championship Series',
          'NLDS' => 'NL Division Series'
        }.freeze

        POSTSEASON_SERIES_ORDER = [
          'World Series', 'AL Championship Series', 'NL Championship Series', 'AL Division Series',
          'NL Division Series', 'AL Wild Card', 'NL Wild Card'
        ].freeze

        def postseason_series
          load_postseason_series
            .group_by { |series, _| postseason_series_name(series) }
            .transform_values { |matchup_games| matchup_games.map { postseason_series_row(_1[1].last) } }
            .sort_by { |series, _| POSTSEASON_SERIES_ORDER.index(series) }
            .map { |series, rows| postseason_series_section(series, rows) }
            .join("\n\n")
        end

        protected

        def load_postseason_series
          @postseason_series = Hash.new { |h, k| h[k] = [] }

          @subreddit.bot.api.schedule(type: :postseason)['dates'].each do |date|
            date['games'].each { process_postseason_game(_1) }
          end

          @postseason_series
        end

        def postseason_series_section(series, rows)
          <<~MARKDOWN
            ## #{series}
            #{table(headers: [[' ', :center]] * 3, rows:)}

          MARKDOWN
        end

        def postseason_series_row(game)
          [
            postseason_team_link(game.dig('teams', 'away', 'team', 'id')),
            postseason_series_score(game),
            postseason_team_link(game.dig('teams', 'home', 'team', 'id'))
          ]
        end

        def postseason_series_score(game)
          to_advance = (game['gamesInSeries'] / 2.0).ceil

          [
            postseason_games_won(game.dig('teams', 'away', 'leagueRecord', 'wins'), to_advance),
            postseason_games_won(game.dig('teams', 'home', 'leagueRecord', 'wins'), to_advance)
          ].join('-')
        end

        def postseason_games_won(wins, to_advance) = (wins == to_advance ? "**#{wins}**" : wins)

        def postseason_team_link(team_id)
          team = api.team(team_id)

          "[#{team.name}][#{team.code.upcase}]"
        end

        def postseason_series_name(series) = POSTSEASON_SERIES_NAMES[series.split('-').first]

        def process_postseason_game(game)
          return unless game.dig('status', 'abstractGameState') == 'Final'

          low_team_id = [game.dig('teams', 'away', 'team', 'id'), game.dig('teams', 'home', 'team', 'id')].min

          # After the wildcard series, all of the descriptions are the same.
          key = "#{game['description'].split(/ Game| - /).first}-#{low_team_id}"

          @postseason_series[key] << game
        end
      end
    end
  end
end

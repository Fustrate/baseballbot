# frozen_string_literal: true

class Baseballbot
  module Templates
    module Sidebars
      module Components
        class Postseason
          include MarkdownHelpers

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

          def initialize(subreddit)
            @subreddit = subreddit

            @postseason_series = Hash.new { |h, k| h[k] = [] }

            load_series
          end

          def to_s
            <<~MARKDOWN.strip
              # #{@subreddit.today.year} Postseason

              #{postseason_series_tables.join("\n\n")}
            MARKDOWN
          end

          protected

          def load_series
            @subreddit.bot.api.schedule(type: :postseason)['dates'].each do |date|
              date['games'].each { process_game(it) }
            end
          end

          def postseason_series_tables
            @postseason_series
              .group_by { |series, _| series_name(series) }
              .transform_values { |matchup_games| matchup_games.map { series_row(it[1].last) } }
              .sort_by { |series, _| POSTSEASON_SERIES_ORDER.index(series) }
              .map { |series, rows| postseason_series_table(series, rows) }
          end

          def postseason_series_table(series, rows)
            <<~MARKDOWN.strip
              ## #{series}
              #{table(headers: [[' ', :center]] * 3, rows:)}
            MARKDOWN
          end

          def series_row(game)
            to_advance = (game['gamesInSeries'] / 2.0).ceil

            [
              team_link(game.dig('teams', 'away', 'team', 'id')),
              [
                series_games_won(game.dig('teams', 'away', 'leagueRecord', 'wins'), to_advance),
                series_games_won(game.dig('teams', 'home', 'leagueRecord', 'wins'), to_advance)
              ].join('-'),
              team_link(game.dig('teams', 'home', 'team', 'id'))
            ]
          end

          def series_games_won(wins, to_advance) = (wins == to_advance ? "**#{wins}**" : wins)

          def team_link(team_id)
            team = @subreddit.bot.api.team(team_id)

            "[#{team.name}][#{team.code.upcase}]"
          end

          def series_name(series)
            return 'World Series' if series.start_with?('World Series')

            POSTSEASON_SERIES_NAMES[series.split('-').first.strip.gsub(/ '[AB]'\z/, '')]
          end

          def process_game(game)
            return if skip_game?(game)

            low_team_id = [game.dig('teams', 'away', 'team', 'id'), game.dig('teams', 'home', 'team', 'id')].min

            # After the wildcard series, all of the descriptions are the same.
            key = "#{game['description'].split(/ Game| - /).first}-#{low_team_id}"

            @postseason_series[key] << game
          end

          def skip_game?(game)
            !['Final', 'Preview', 'In Progress', 'Live'].include?(game.dig('status', 'abstractGameState')) ||
              game['ifNecessary'] == 'Y' || ['TBD', 'NL Stadium', 'AL Stadium'].include?(game.dig('venue', 'name'))
          end
        end
      end
    end
  end
end

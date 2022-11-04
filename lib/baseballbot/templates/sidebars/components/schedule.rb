# frozen_string_literal: true

class Baseballbot
  module Templates
    module Sidebars
      module Components
        class Schedule
          include MarkdownHelpers

          def initialize(subreddit)
            @subreddit = subreddit
          end

          # Used by TB sidebar
          def month_games
            start_date = Date.civil(@subreddit.today.year, @subreddit.today.month, 1)
            end_date = Date.civil(@subreddit.today.year, @subreddit.today.month, -1)

            team_schedule.games_between(start_date, end_date)
              .flat_map { |_, day| day[:games] }
          end

          # Used by CLE sidebar
          def previous_games(limit, team: nil)
            games = []
            start_date = @subreddit.today - limit - 7

            # Go backwards an extra week to account for off days
            schedule_between(start_date, @subreddit.today, team).reverse_each do |day|
              next if day[:date] > @subreddit.today

              games.concat day[:games].keep_if(&:final?)

              break if games.count >= limit
            end

            games.first(limit)
          end

          # Used by TOR, MIN, and CLE sidebars
          def upcoming_games(limit, team: nil)
            games = []
            end_date = @subreddit.today + limit + 7

            # Go forward an extra week to account for off days
            schedule_between(@subreddit.today, end_date, team).each do |day|
              next if day[:date] < @subreddit.today

              games.concat day[:games].reject(&:final?)

              break if games.count >= limit
            end

            games.first(limit)
          end

          # Used by CIN sidebar
          def next_game_str(date_format: '%-m/%-d', team: nil)
            game = upcoming_games(1, team:).first

            return '???' unless game

            format(
              '%<date>s %<team>s %<dir>s %<opponent>s %<time>s',
              date: game.date.strftime(date_format),
              team: @subreddit.team.name,
              dir: game.home_team? ? 'vs.' : '@',
              opponent: game.opponent.name,
              time: game.date.strftime('%-I:%M %p')
            )
          end

          # Used by CIN sidebar
          def last_game_str(date_format: '%-m/%-d', team: nil)
            game = previous_games(1, team:).first

            return '???' unless game

            format(
              '%<date>s %<team>s %<team_runs>s %<opponent>s %<opponent_runs>s',
              date: game.date.strftime(date_format),
              team: @subreddit.team.name,
              team_runs: game.score[0],
              opponent: game.opponent.name,
              opponent_runs: game.score[1]
            )
          end

          protected

          def schedule_between(start_date, end_date, team)
            team_schedule
              .games_between(start_date, end_date, team: team || @subreddit.team.id)
              .values
          end

          # This is the schedule generator for this subreddit, not necessarily this subreddit's team.
          def team_schedule
            @team_schedule ||= SubredditScheduleGenerator.new(subreddit: @subreddit)
          end

          class SubredditScheduleGenerator
            def initialize(subreddit:)
              @subreddit = subreddit
            end

            def games_between(start_date, end_date, team: nil)
              SubredditSchedule.new(
                subreddit: @subreddit,
                team_id: team || @subreddit.team&.id
              ).generate(start_date, end_date)
            end
          end

          # This allows us to generate a schedule for a team other than the one belonging to the subreddit.
          class SubredditSchedule
            SCHEDULE_HYDRATION = 'team(venue(timezone)),game(content(summary)),linescore,broadcasts(all)'

            def initialize(subreddit:, team_id:)
              @subreddit = subreddit
              @team_id = team_id
            end

            def generate(start_date, end_date)
              days = build_date_hash(start_date, end_date)

              calendar_dates(start_date, end_date).each do |calendar_date|
                calendar_date['games'].each do |data|
                  date = adjust_game_time(data['gameDate'])

                  game = team_calendar_game(data:, date:)

                  days[date.strftime('%F')][:games] << game if game.visible?
                end
              end

              days
            end

            protected

            # Rescheduled games, when converted to the local time zone, end up in the previous day.
            def adjust_game_time(timestamp)
              Baseballbot::Utility.parse_time(timestamp.sub('03:33', '12:00'), in_time_zone: @subreddit.timezone)
            end

            def build_date_hash(start_date, end_date)
              start_date.upto(end_date).to_h { [_1.strftime('%F'), { date: _1, games: [] }] }
            end

            def calendar_dates(start_date, end_date)
              @subreddit.bot.api.schedule(
                teamId: @team_id,
                startDate: start_date.strftime('%m/%d/%Y'),
                endDate: end_date.strftime('%m/%d/%Y'),
                sportId: 1,
                eventTypes: 'primary',
                scheduleTypes: 'games',
                hydrate: SCHEDULE_HYDRATION
              )['dates']
            end

            def team_calendar_game(data:, date:)
              TeamCalendarGame.new(api: @subreddit.bot.api, data:, date:, team_id: @team_id)
            end
          end

          class TeamCalendarGame
            attr_reader :flag, :opponent_flag, :team_id, :game_pk, :date, :where

            def initialize(api:, data:, team_id:, date:)
              @api = api
              @data = data
              @team_id = team_id
              @date = date

              @flag, @opponent_flag = home_team? ? %w[home away] : %w[away home]
              @game_pk = data['gamePk']
              @where = home_team? ? 'vs' : '@'
            end

            def home_team?
              @home_team ||= @data.dig('teams', 'away', 'team', 'id') != @team_id
            end

            def opponent
              @opponent ||= @api.team(@data.dig('teams', opponent_flag, 'team', 'id'))
            end

            def final?
              @final ||= %w[F C D FT FR].include?(@data['status']['statusCode'])
            end

            def outcome
              return unless final?

              return 'Tied' if score[0] == score[1]

              score[0] > score[1] ? 'Won' : 'Lost'
            end

            def score
              @score ||= [
                @data.dig('teams', flag, 'score'),
                @data.dig('teams', opponent_flag, 'score')
              ]
            end

            def status
              return 'Delayed' if @data['status']['statusCode'].start_with? 'D'

              return "#{outcome} #{score.join '-'}" if final?

              [
                @date.strftime('%-I:%M'),
                tv_stations
              ].reject(&:empty?).join(', ')
            end

            def tv_stations
              return '' unless @data['broadcasts']

              @tv_stations ||= @data['broadcasts']
                .filter_map { _1['callSign'] if _1['type'] == 'TV' && _1['language'] == 'en' && _1['homeAway'] == flag }
                .join(', ')
            end

            def wlt
              return '' unless final?

              return 'T' if score[0] == score[1]

              score[0] > score[1] ? 'W' : 'L'
            end

            def visible? = current_team_game? && @data['ifNecessary'] != 'Y' && !@data['rescheduleDate']

            protected

            def current_team_game?
              @data.dig('teams', 'away', 'team', 'id') == @team_id ||
                @data.dig('teams', 'home', 'team', 'id') == @team_id
            end
          end
        end
      end
    end
  end
end

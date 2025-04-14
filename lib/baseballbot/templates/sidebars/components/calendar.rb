# frozen_string_literal: true

class Baseballbot
  module Templates
    module Sidebars
      module Components
        class Calendar
          include MarkdownHelpers

          attr_reader :subreddit

          def initialize(subreddit)
            @subreddit = subreddit

            @cell_method = method(subreddit.name == 'buccos' ? :buccos_cell : :cell)
          end

          def to_s
            cells = month_schedule.map do |_, day|
              @cell_method.call(day[:date].day, day[:games])
            end

            markdown_calendar(cells, month_schedule)
          end

          protected

          def month_schedule
            @month_schedule ||= SubredditSchedule.new(subreddit: @subreddit, team_id: @subreddit.team&.id).generate(
              Date.civil(@subreddit.today.year, @subreddit.today.month, 1),
              Date.civil(@subreddit.today.year, @subreddit.today.month, -1)
            )
          end

          def cell(date, games)
            num = "^#{date}"

            return num if games.empty?

            sub_name = @subreddit.code_to_subreddit_name(games.first.opponent.code)
            link = "[](/r/#{sub_name} \"#{games.map(&:status).join(', ')}\")"

            return "**#{num} #{link}**" if games[0].home_team?

            "*#{num} #{link}*"
          end

          def buccos_cell(date, games)
            return "#{format('%02d', date)} [](/offday)[](/offdaybar)" if games.empty?

            game = games.first

            format(
              '%<date>02d [%<time>s](/r/%<subreddit>s "%<status>s")[](/%<flag>s)',
              date:,
              time: game.date.strftime('%-I:%M'),
              subreddit: @subreddit.code_to_subreddit_name(game.opponent.code),
              flag: game.home_team? ? 'Home' : 'Away',
              status: game.status
            )
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
              start_date.upto(end_date).to_h { [it.strftime('%F'), { date: it, games: [] }] }
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
            attr_reader :flag, :opponent_flag, :team_id, :game_pk, :date

            def initialize(api:, data:, team_id:, date:)
              @api = api
              @data = data
              @team_id = team_id
              @date = date

              @flag, @opponent_flag = home_team? ? %w[home away] : %w[away home]
              @game_pk = data['gamePk']
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
                .filter_map { it['callSign'] if it['type'] == 'TV' && it['language'] == 'en' && it['homeAway'] == flag }
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

# frozen_string_literal: true

require_relative 'markdown_calendar'
require_relative 'subreddit_schedule_generator'

class Baseballbot
  module Templates
    module Shared
      module Calendar
        def month_calendar(downcase: false)
          cells = month_schedule.map do |_, day|
            cell(day[:date].day, day[:games], downcase:)
          end

          MarkdownCalendar.generate(cells, month_schedule)
        end

        def month_schedule
          team_schedule.games_between(
            Date.civil(Date.today.year, Date.today.month, 1),
            Date.civil(Date.today.year, Date.today.month, -1)
          )
        end

        def month_games
          start_date = Date.civil(Date.today.year, Date.today.month, 1)
          end_date = Date.civil(Date.today.year, Date.today.month, -1)

          team_schedule.games_between(start_date, end_date)
            .flat_map { |_, day| day[:games] }
        end

        def previous_games(limit, team: nil)
          games = []
          start_date = Date.today - limit - 7

          # Go backwards an extra week to account for off days
          schedule_between(start_date, Date.today, team).reverse_each do |day|
            next if day[:date] > Date.today

            games.concat day[:games].keep_if(&:final?)

            break if games.count >= limit
          end

          games.first(limit)
        end

        def upcoming_games(limit, team: nil)
          games = []
          end_date = Date.today + limit + 7

          # Go forward an extra week to account for off days
          schedule_between(Date.today, end_date, team).each do |day|
            next if day[:date] < Date.today

            games.concat day[:games].reject(&:final?)

            break if games.count >= limit
          end

          games.first(limit)
        end

        def schedule_between(start_date, end_date, team)
          team_schedule
            .games_between(start_date, end_date, team: team || @subreddit.team.id)
            .values
        end

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

        # This is the schedule generator for this subreddit, not necessarily this subreddit's team.
        def team_schedule
          @team_schedule ||= SubredditScheduleGenerator.new(api: @subreddit.bot.api, subreddit: @subreddit)
        end

        def cell(date, games, **options)
          num = "^#{date}"

          return num if games.empty?

          sub_name = cell_subreddit(games.first.opponent.code, options[:downcase])
          link = "[](/r/#{sub_name} \"#{games.map(&:status).join(', ')}\")"

          return "**#{num} #{link}**" if games[0].home_team?

          "*#{num} #{link}*"
        end

        # Spring training games sometimes are against colleges, so sometimes
        # the team sub is nil
        def cell_subreddit(code, downcase)
          team_sub = subreddit(code)

          downcase ? team_sub&.downcase : team_sub
        end
      end
    end
  end
end

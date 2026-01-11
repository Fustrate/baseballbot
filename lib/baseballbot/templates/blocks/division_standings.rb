# frozen_string_literal: true

class Baseballbot
  module Templates
    module Blocks
      class DivisionStandings < Block
        def render
          <<~MARKDOWN
            #{interpolate(attributes['title'] || '## {{year}} Division Standings')}

            #{render_standings_table}
          MARKDOWN
        end

        protected

        def render_standings_table
          table(headers: table_headers, rows: table_rows)
        end

        def table_headers
          columns.map do |column|
            case column
            when 'team_logo' then ['Team', :left]
            when 'wins' then ['W', :center]
            when 'losses' then ['L', :center]
            when 'percent' then ['PCT', :center]
            when 'games_back' then ['GB', :center]
            when 'last_ten' then ['L10', :center]
            when 'streak' then ['STRK', :center]
            when 'home_record' then ['Home', :center]
            when 'road_record' then ['Road', :center]
            when 'run_diff' then ['RD', :center]
            else
              [column.upcase, :center]
            end
          end
        end

        def table_rows
          division_standings.map do |team|
            columns.map do |column|
              case column
              when 'team_logo'
                team_logo(team)
              when 'team_name'
                team.name
              when 'wins'
                team.wins
              when 'losses'
                team.losses
              when 'percent'
                team.percent
              when 'games_back'
                team.games_back
              when 'last_ten'
                team.last_ten
              when 'streak'
                team.streak
              when 'home_record'
                team.home_record
              when 'road_record'
                team.road_record
              when 'run_diff'
                team.run_diff.positive? ? "+#{team.run_diff}" : team.run_diff.to_s
              else
                team.respond_to?(column) ? team.send(column) : ''
              end
            end
          end
        end

        def team_logo(team)
          subreddit_name = subreddit.code_to_subreddit_name(team.abbreviation)

          if team.current
            "**[](/r/#{subreddit_name})**"
          else
            "[](/r/#{subreddit_name})"
          end
        end

        def division_standings
          @division_standings ||= Components::Standings.new(subreddit).teams_in_division(subreddit.team.division_id)
        end

        def columns
          @columns ||= attributes['columns'] || default_columns
        end

        def default_columns
          %w[team_logo wins losses percent games_back last_ten]
        end
      end
    end
  end
end

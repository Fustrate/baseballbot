# frozen_string_literal: true

class Baseballbot
  module Template
    class GameThread
      module Components
        def header = "#{away_team.name} (#{away_record}) @ #{home_team.name} (#{home_record})"

        def first_pitch = "**First Pitch**: #{start_time_local.strftime('%-I:%M %p')} at #{venue_name}"

        def probables_and_media
          table columns: %w[Team Starter TV Radio], data: [
            [team_link(away_team), pitcher_line(probable_away_starter), away_tv, away_radio],
            [team_link(home_team), pitcher_line(probable_home_starter), home_tv, home_radio]
          ]
        end

        def box_score
          [batters_table(:home), pitchers_table(:home), batters_table(:away), pitchers_table(:away)].join("\n\n")
        end

        protected

        def team_link(team) = link_to(team.name, "/r/#{subreddit(team.code)}")
      end
    end
  end
end

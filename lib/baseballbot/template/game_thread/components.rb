# frozen_string_literal: true

class Baseballbot
  module Template
    class GameThread
      module Components
        def header
          <<~MARKDOWN
            [](http://mlb.mlb.com/images/2017_ipad/684/#{away_team.file_code}#{home_team.file_code}_684.jpg)

            ### #{away_team.name} (#{away_record}) @ #{home_team.name} (#{home_record})

            **First Pitch**: #{start_time_local.strftime('%-I:%M %p')} at #{venue_name}
          MARKDOWN
        end

        def first_pitch = "**First Pitch**: #{start_time_local.strftime('%-I:%M %p')} at #{venue_name}"

        def final_score = "**Final Score**: #{away_team.name} #{runs(:away)}, #{home_team.name} #{runs(:home)}"

        def probables_and_media
          table headers: %w[Team Starter TV Radio], rows: [
            [team_link(away_team), pitcher_line(probable_away_starter), away_tv, away_radio],
            [team_link(home_team), pitcher_line(probable_home_starter), home_tv, home_radio]
          ]
        end

        def box_score_section
          <<~MARKDOWN
            ### Box Score

            #{box_score}
          MARKDOWN
        end

        def box_score
          [batters_table(:home), pitchers_table(:home), batters_table(:away), pitchers_table(:away)].join("\n\n")
        end

        def metadata_section
          <<~MARKDOWN
            #{table(headers: %w[Attendance Weather Wind], rows: [attendance, weather, wind])}

            #{table(headers: umpires.keys.map { [_1, :center] }, rows: umpires.values)}
          MARKDOWN
        end

        protected

        def team_link(team) = link_to(team.name, "/r/#{subreddit(team.code)}")
      end
    end
  end
end

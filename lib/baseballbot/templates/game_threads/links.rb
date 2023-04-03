# frozen_string_literal: true

class Baseballbot
  module Templates
    module GameThreads
      module Links
        def gameday_link = "https://www.mlb.com/gameday/#{game_pk}"

        def game_graph_link
          "http://www.fangraphs.com/livewins.aspx?date=#{start_time_et.strftime '%F'}&team=#{team.name}" \
            "&dh=#{game_data.dig('game', 'gameNumber') - 1}&season=#{start_time_et.year}"
        end

        def savant_feed_link = "https://baseballsavant.mlb.com/gamefeed?gamePk=#{game_pk}"

        def thumbnail
          "[](http://mlb.mlb.com/images/2017_ipad/684/#{away_team.file_code}#{home_team.file_code}_684.jpg)"
        end

        # Default to the /r/baseball discord server
        def discord_link = @subreddit.options['discord_invite'] || 'https://discord.gg/rbaseball'
      end
    end
  end
end

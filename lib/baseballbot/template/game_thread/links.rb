# frozen_string_literal: true

class Baseballbot
  module Template
    class GameThread
      module Links
        def player_link(player, title: nil)
          link_to(player_name(player), url: player_url(player['id'] || player.dig('person', 'id')), title:)
        end

        def player_url(id) = "http://mlb.mlb.com/team/player.jsp?player_id=#{id}"

        def gameday_link(mode: nil) = ["https://www.mlb.com/gameday/#{game_pk}", mode].compact.join('/')

        def game_graph_link
          "http://www.fangraphs.com/livewins.aspx?date=#{start_time_et.strftime '%F'}&team=#{team.name}" \
            "&dh=#{game_data.dig('game', 'gameNumber') - 1}&season=#{date.year}"
        end

        def savant_feed_link = "https://baseballsavant.mlb.com/gamefeed?gamePk=#{game_pk}"

        def thumbnail
          "[](http://mlb.mlb.com/images/2017_ipad/684/#{away_team.file_code}#{home_team.file_code}_684.jpg)"
        end

        # Default to the /r/baseball discord server
        def discord_link = @subreddit.options[:discord_invite] || 'https://discordapp.com/invite/Kqs2KzG'
      end
    end
  end
end

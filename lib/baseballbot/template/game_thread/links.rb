# frozen_string_literal: true

class Baseballbot
  module Template
    class GameThread
      module Links
        def player_link(player, title: nil)
          url = player_url(player['id'] || player.dig('person', 'id'))
          link_to player_name(player), url:, title:
        end

        def player_url(id) = "http://mlb.mlb.com/team/player.jsp?player_id=#{id}"

        def gameday_link = "https://www.mlb.com/gameday/#{game_pk}"

        def game_graph_link
          "http://www.fangraphs.com/livewins.aspx?date=#{start_time_et.strftime '%F'}&team=#{team.name}" \
            "&dh=#{game_data.dig('game', 'gameNumber') - 1}&season=#{date.year}"
        end

        def savant_feed_link = "https://baseballsavant.mlb.com/gamefeed?gamePk=#{game_pk}"

        def game_notes_link(mlb_team) = "http://www.mlb.com/mlb/presspass/gamenotes.jsp?c_id=#{mlb_team.file_code}"
      end
    end
  end
end

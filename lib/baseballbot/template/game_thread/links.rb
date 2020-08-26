# frozen_string_literal: true

class Baseballbot
  module Template
    class GameThread
      module Links
        def player_link(player, title: nil)
          url = player_url(player['id'] || player.dig('person', 'id'))
          link_to player_name(player), url: url, title: title
        end

        def player_url(id)
          "http://mlb.mlb.com/team/player.jsp?player_id=#{id}"
        end

        def gameday_link
          format(
            'https://www.mlb.com/gameday/%<away>s-vs-%<home>s/%<date>s/%<game_pk>d' \
            '#game_state=preview,lock_state=preview',
            away: game_data.dig('teams', 'away', 'teamName').downcase.tr(' ', '-'),
            home: game_data.dig('teams', 'home', 'teamName').downcase.tr(' ', '-'),
            date: date.strftime('%Y/%m/%d'),
            game_pk: game_pk
          )
        end

        def game_graph_link
          "http://www.fangraphs.com/livewins.aspx?date=#{date.strftime '%F'}&team=#{team.name}" \
          "&dh=#{game_data.dig('game', 'gameNumber') - 1}&season=#{date.year}"
        end

        def strikezone_map_link
          'http://www.brooksbaseball.net/pfxVB/zoneTrack.php?' \
          "#{date.strftime 'month=%m&day=%d&year=%Y'}&game=gid_#{gid}%2F"
        end

        def game_notes_link(mlb_team)
          "http://www.mlb.com/mlb/presspass/gamenotes.jsp?c_id=#{mlb_team.file_code}"
        end
      end
    end
  end
end

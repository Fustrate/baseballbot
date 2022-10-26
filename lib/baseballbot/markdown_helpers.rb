# frozen_string_literal: true

class Baseballbot
  module MarkdownHelpers
    ALIGNMENT = {
      center: ':-:',
      left: '-',
      right: '-:'
    }.freeze

    def table(headers: [], rows: [])
      header_cells = []
      alignment_cells = []

      headers.each do |column|
        header, alignment = Array(column)

        header_cells << header.to_s
        alignment_cells << ALIGNMENT.fetch(alignment, ALIGNMENT[:left])
      end

      <<~MARKDOWN.strip
        |#{header_cells.join('|')}|
        |#{alignment_cells.join('|')}|
        |#{rows.map { _1.join('|') }.join("|\n|")}|
      MARKDOWN
    end

    def player_link(player, title: nil)
      url = player_url(player['id'] || player.dig('person', 'id'))

      return "[#{player_name(player)}](#{url} \"#{title.gsub('"', '\\"')}\")" if title

      "[#{player_name(player)}](#{url})"
    end

    protected

    def player_name(player)
      return 'TBA' unless player

      player['boxscoreName'] ||
        player.dig('name', 'boxscore') ||
        template.game_data.dig('players', "ID#{player['person']['id']}", 'boxscoreName')
    end

    def player_url(id) = "https://www.mlb.com/player/#{id}"
  end
end

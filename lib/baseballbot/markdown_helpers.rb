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
        |#{rows.map { it.join('|') }.join("|\n|")}|
      MARKDOWN
    end

    def player_link(player, title: nil)
      url = player_url(player['id'] || player.dig('person', 'id'))

      return "[#{player_name(player)}](#{url} \"#{title.gsub('"', '\\"')}\")" if title

      "[#{player_name(player)}](#{url})"
    end

    def markdown_calendar(cells, dates)
      table(headers: 'SMTWTFS'.chars.map { [it, :center] }, rows: calendar_rows(cells, dates))
    end

    protected

    def calendar_rows(cells, dates)
      [
        *([' '] * dates.values.first[:date].wday),
        *cells,
        *([' '] * (6 - dates.values.last[:date].wday))
      ].each_slice(7)
    end

    def player_name(player)
      return 'TBA' unless player

      player['boxscoreName'] ||
        player.dig('name', 'boxscore') ||
        @game_thread.game_data.dig('players', "ID#{player['person']['id']}", 'boxscoreName')
    end

    def player_url(id) = "https://www.mlb.com/player/#{id}"
  end
end

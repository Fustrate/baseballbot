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

        header_text = header.to_s.strip

        header_cells << (header_text.empty? ? '&nbsp;' : header_text)
        alignment_cells << ALIGNMENT.fetch(alignment, ALIGNMENT[:left])
      end

      <<~MARKDOWN.strip
        |#{header_cells.join('|')}|
        |#{alignment_cells.join('|')}|
        |#{rows.map { it.join('|') }.join("|\n|")}|
      MARKDOWN
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
  end
end

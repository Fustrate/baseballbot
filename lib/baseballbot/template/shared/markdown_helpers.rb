# frozen_string_literal: true

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
end

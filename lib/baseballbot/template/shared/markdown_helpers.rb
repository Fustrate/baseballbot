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

    <<~MARKDOWN
      |#{header_cells.join('|')}|
      |#{alignment_cells.join('|')}|
      |#{rows.map { _1.join('|') }.join("|\n|")}|
    MARKDOWN
  end

  def link_to(text = '', **options)
    title = %( "#{options[:title]}") if options[:title]

    return "[#{text}](/r/#{options[:sub]}#{title})" if options[:sub]
    return "[#{text}](#{options[:url]}#{title})" if options[:url]
    return "[#{text}](/u/#{options[:user]}#{title})" if options[:user]

    "[#{text}](/##{title})"
  end
end

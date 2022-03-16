# frozen_string_literal: true

module MarkdownHelpers
  ALIGNMENT = {
    center: ':-:',
    left: '-',
    right: '-:'
  }.freeze

  def bold(text) = "**#{text}**"

  def italic(text) = "*#{text}*"

  def sup(text) = "^(#{text})"

  def pct(percent) = format('%0.3<percent>f', percent:).sub(/\A0+/, '')

  def gb(games_back) = games_back.gsub(/\.0$/, '')

  def table(columns: [], data: [])
    headers = []
    alignment = []

    columns.each do |column|
      headers << header_for(column)
      alignment << alignment_for(column)
    end

    <<~TABLE
      #{headers.join('|')}|
      #{alignment.join('|')}|
      #{data.map { _1.join('|') }.join("\n")}|
    TABLE
  end

  def header_for(column) = column.is_a?(Array) ? column[0] : column.to_s

  def alignment_for(column) = ALIGNMENT[Array(column)[1] || :left] || ALIGNMENT[:left]

  def link_to(text = '', **options)
    title = %( "#{options[:title]}") if options[:title]

    return "[#{text}](/r/#{options[:sub]}#{title})" if options[:sub]
    return "[#{text}](#{options[:url]}#{title})" if options[:url]
    return "[#{text}](/u/#{options[:user]}#{title})" if options[:user]

    "[#{text}](/##{title})"
  end
end

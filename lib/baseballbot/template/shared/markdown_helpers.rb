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
    alignments = []

    columns.each do |column|
      header, alignment = Array(column)

      headers << header.to_s
      alignments << ALIGNMENT.fetch(alignment, ALIGNMENT[:left])
    end

    <<~TABLE
      #{headers.join('|')}|
      #{alignments.join('|')}|
      #{data.map { _1.join('|') }.join("\n")}|
    TABLE
  end

  def link_to(text = '', **options)
    title = %( "#{options[:title]}") if options[:title]

    return "[#{text}](/r/#{options[:sub]}#{title})" if options[:sub]
    return "[#{text}](#{options[:url]}#{title})" if options[:url]
    return "[#{text}](/u/#{options[:user]}#{title})" if options[:user]

    "[#{text}](/##{title})"
  end
end

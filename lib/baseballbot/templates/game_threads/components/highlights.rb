# frozen_string_literal: true

class Baseballbot
  module Templates
    module GameThreads
      module Components
        class Highlights
          include MarkdownHelpers

          TABLE_HEADERS = %w[Description Length].freeze

          def initialize(game_thread)
            @game_thread = game_thread
          end

          def to_s
            return '' unless highlights.any?

            <<~MARKDOWN.strip
              ### Highlights

              #{table(headers: TABLE_HEADERS, rows: table_rows)}
            MARKDOWN
          end

          protected

          def table_rows = highlights.map { ["[#{_1[:blurb]}](#{_1[:hd]})", _1[:duration]] }

          def highlights
            @highlights ||= (fetch_highlights if @game_thread.started?) || []
          end

          def fetch_highlights
            @game_thread.content.dig('highlights', 'highlights', 'items')
              &.sort_by { _1['date'] }
              &.map { process_media(_1) }
              &.compact
          end

          def process_media(media)
            return unless media['type'] == 'video'

            {
              # code: media_team_code(media),
              headline: media['headline'].strip,
              blurb: media_blurb(media),
              duration: media_duration(media),
              # sd: playback(media, 'FLASH_1200K_640X360'),
              hd: hd_playback_url(media)
            }
          end

          def media_blurb(media) = media['blurb']&.strip&.gsub(/^[A-Z@]+: /, '')&.tr('|', '-') || ''

          def media_duration(media) = media['duration']&.strip&.gsub(/^00:0?/, '') || ''

          def hd_playback_url(media) = media['playbacks'].find { _1['name'] == 'mp4Avc' }&.dig('url')

          def media_team_code(media) = media.dig('image', 'title')&.match(/^\d+([a-z]+)/i)&.captures&.first
        end
      end
    end
  end
end

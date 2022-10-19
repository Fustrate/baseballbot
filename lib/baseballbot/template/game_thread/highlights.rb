# frozen_string_literal: true

class Baseballbot
  module Template
    class GameThread
      module Highlights
        def highlights_section
          return unless started? && highlights.any?

          <<~MARKDOWN
            ### Highlights

            #{highlights_table.strip}
          MARKDOWN
        end

        protected

        def highlights_table
          table(
            headers: %w[Description Length Video],
            rows: highlights.map { [_1[:blurb], _1[:duration], link_to('Video', url: _1[:hd])] }
          )
        end

        def highlights
          return [] unless started?

          @highlights ||= fetch_highlights || []
        end

        def fetch_highlights
          content.dig('highlights', 'highlights', 'items')
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

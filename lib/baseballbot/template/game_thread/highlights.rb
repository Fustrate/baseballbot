# frozen_string_literal: true

class Baseballbot
  module Template
    class GameThread
      module Highlights
        def highlights_section
          return unless final? && highlights.any?

          <<~MARKDOWN
            ### Highlights

            #{highlights_table}
          MARKDOWN
        end

        def highlights_table
          lines = highlights.map do |highlight|
            [
              # link_to('', url: "/#{highlight[:code]}"),
              highlight[:blurb],
              highlight[:duration],
              link_to('Video', url: highlight[:hd])
            ].join('|')
          end

          <<~MARKDOWN
            Description|Length|Video
            -|-|-
            #{lines.join("\n")}
          MARKDOWN
        end

        protected

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

        def media_blurb(media) = media['blurb']&.strip&.gsub(/^[A-Z@]+: /, '') || ''

        def media_duration(media) = media['duration']&.strip&.gsub(/^00:0?/, '') || ''

        def hd_playback_url(media)
          media['playbacks']
            .find { _1['name'] == 'mp4Avc' }
            &.dig('url')
        end

        def media_team_code(media) = media.dig('image', 'title')&.match(/^\d+([a-z]+)/i)&.captures&.first
      end
    end
  end
end

# frozen_string_literal: true

class Baseballbot
  module Template
    class GameThread
      module Media
        HOME_FEED_TYPES = %w[HOME NATIONAL].freeze
        AWAY_FEED_TYPES = %w[AWAY NATIONAL].freeze

        def free_game? = content.dig('media', 'freeGame')

        def enhanced_game? = content.dig('media', 'enhancedGame')

        def away_tv
          tv_feeds
            .select { AWAY_FEED_TYPES.include?(_1['mediaFeedType']) }
            .map { _1['callLetters'] }
            .join(', ')
        end

        def home_tv
          tv_feeds
            .select { HOME_FEED_TYPES.include?(_1['mediaFeedType']) }
            .map { _1['callLetters'] }
            .join(', ')
        end

        def away_radio
          radio_feeds
            .select { AWAY_FEED_TYPES.include?(_1['type']) }
            .sort_by { _1['language'] == 'en' ? 0 : 1 }
            .map { radio_name(_1) }
            .join(', ')
        end

        def home_radio
          radio_feeds
            .select { HOME_FEED_TYPES.include?(_1['type']) }
            .sort_by { _1['language'] == 'en' ? 0 : 1 }
            .map { radio_name(_1) }
            .join(', ')
        end

        protected

        def tv_feeds
          @tv_feeds ||= media_with_title('MLBTV')
        end

        def radio_feeds
          @radio_feeds ||= media_with_title('Audio')
        end

        def media_with_title(title)
          content.dig('media', 'epg')
            &.detect { _1['title'] == title }
            &.fetch('items') || []
        end

        def radio_name(item)
          item['language'] == 'en' ? item['callLetters'] : "#{item['callLetters']} (#{item['language'].upcase})"
        end
      end
    end
  end
end

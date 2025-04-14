# frozen_string_literal: true

class Baseballbot
  module Templates
    module GameThreads
      module Components
        class Media
          include MarkdownHelpers

          HOME_FEED_TYPES = %w[HOME NATIONAL].freeze
          AWAY_FEED_TYPES = %w[AWAY NATIONAL].freeze

          def initialize(game_thread)
            @game_thread = game_thread
          end

          def to_s
            table headers: %w[Team TV Radio], rows: [
              [team_link(@game_thread.away_team), tv_feeds(:away), radio_feeds(:away)],
              [team_link(@game_thread.home_team), tv_feeds(:home), radio_feeds(:home)]
            ]
          end

          protected

          def team_link(team) = "[#{team.name}](/r/#{@game_thread.subreddit.code_to_subreddit_name(team.code)})"

          def tv_feeds(flag)
            television_feeds
              .select { (flag == :home ? HOME_FEED_TYPES : AWAY_FEED_TYPES).include?(it['mediaFeedType']) }
              .map { it['callLetters'] }
              .join(', ')
          end

          def radio_feeds(flag)
            audio_feeds
              .select { (flag == :home ? HOME_FEED_TYPES : AWAY_FEED_TYPES).include?(it['type']) }
              .sort_by { it['language'] == 'en' ? 0 : 1 }
              .map { it['language'] == 'en' ? it['callLetters'] : "#{it['callLetters']} (#{it['language'].upcase})" }
              .join(', ')
          end

          def television_feeds
            @television_feeds ||= @game_thread.content.dig('media', 'epg')
              &.detect { it['title'] == 'MLBTV' }
              &.fetch('items') || []
          end

          def audio_feeds
            @audio_feeds ||= @game_thread.content.dig('media', 'epg')
              &.detect { it['title'] == 'Audio' }
              &.fetch('items') || []
          end
        end
      end
    end
  end
end

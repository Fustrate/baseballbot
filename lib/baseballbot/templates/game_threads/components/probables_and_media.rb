# frozen_string_literal: true

class Baseballbot
  module Templates
    module GameThreads
      class ProbablesAndMedia
        include MarkdownHelpers

        HOME_FEED_TYPES = %w[HOME NATIONAL].freeze
        AWAY_FEED_TYPES = %w[AWAY NATIONAL].freeze

        attr_reader :template

        def initialize(template)
          @template = template
        end

        def to_s
          table headers: %w[Team Starter TV Radio], rows: [
            [team_link(away_team), probable_starter_line('away'), tv_feeds(:away), radio_feeds(:away)],
            [team_link(home_team), probable_starter_line('home'), tv_feeds(:home), radio_feeds(:home)]
          ]
        end

        protected

        def team_link(team) = "[#{team.name}](/r/#{subreddit(team.code)}"

        def probable_starter_line(flag)
          pitcher_id = template.game_data.dig('probablePitchers', flag, 'id')

          pitcher_line(template.boxscore.dig('teams', flag, 'players', "ID#{pitcher_id}")) if pitcher_id
        end

        def tv_feeds(flag)
          television_feeds
            .select { (flag == :home ? HOME_FEED_TYPES : AWAY_FEED_TYPES).include?(_1['mediaFeedType']) }
            .map { _1['callLetters'] }
            .join(', ')
        end

        def radio_feeds(flag)
          audio_feeds
            .select { (flag == :home ? HOME_FEED_TYPES : AWAY_FEED_TYPES).include?(_1['type']) }
            .sort_by { _1['language'] == 'en' ? 0 : 1 }
            .map { _1['language'] == 'en' ? _1['callLetters'] : "#{_1['callLetters']} (#{_1['language'].upcase})" }
            .join(', ')
        end

        def television_feeds
          @television_feeds ||= media_with_title('MLBTV')
        end

        def audio_feeds
          @audio_feeds ||= media_with_title('Audio')
        end

        def media_with_title(title)
          content.dig('media', 'epg')
            &.detect { _1['title'] == title }
            &.fetch('items') || []
        end
      end
    end
  end
end
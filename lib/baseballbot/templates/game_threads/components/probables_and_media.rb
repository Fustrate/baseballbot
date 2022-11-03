# frozen_string_literal: true

class Baseballbot
  module Templates
    module GameThreads
      module Components
        class ProbablesAndMedia
          include MarkdownHelpers

          HOME_FEED_TYPES = %w[HOME NATIONAL].freeze
          AWAY_FEED_TYPES = %w[AWAY NATIONAL].freeze

          def initialize(game_thread)
            @game_thread = game_thread
          end

          def to_s
            table headers: %w[Team Starter TV Radio], rows: [
              [team_link(@game_thread.away_team), probable_starter_line('away'), tv_feeds(:away), radio_feeds(:away)],
              [team_link(@game_thread.home_team), probable_starter_line('home'), tv_feeds(:home), radio_feeds(:home)]
            ]
          end

          protected

          def team_link(team) = "[#{team.name}](/r/#{@game_thread.subreddit.code_to_subreddit_name(team.code)})"

          def probable_starter_line(flag)
            pitcher_id = @game_thread.game_data.dig('probablePitchers', flag, 'id')

            pitcher_line(@game_thread.boxscore.dig('teams', flag, 'players', "ID#{pitcher_id}")) if pitcher_id
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
            @television_feeds ||= @game_thread.content.dig('media', 'epg')
              &.detect { _1['title'] == 'MLBTV' }
              &.fetch('items') || []
          end

          def audio_feeds
            @audio_feeds ||= @game_thread.content.dig('media', 'epg')
              &.detect { _1['title'] == 'Audio' }
              &.fetch('items') || []
          end

          def pitcher_line(pitcher)
            return 'TBA' unless pitcher

            format '[%<name>s](%<url>s) (%<wins>d-%<losses>d, %<era>s ERA)',
                   name: pitcher.dig('person', 'fullName'),
                   url: player_url(pitcher.dig('person', 'id')),
                   wins: pitcher.dig('seasonStats', 'pitching', 'wins').to_i,
                   losses: pitcher.dig('seasonStats', 'pitching', 'losses').to_i,
                   era: pitcher.dig('seasonStats', 'pitching', 'era')
          end
        end
      end
    end
  end
end

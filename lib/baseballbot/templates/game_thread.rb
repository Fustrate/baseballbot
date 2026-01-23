# frozen_string_literal: true

class Baseballbot
  module Templates
    class GameThread < Template
      include GameThreads::Components
      include GameThreads::Game
      include GameThreads::Links
      include GameThreads::Teams

      attr_reader :post_id, :game_pk

      def initialize(type:, subreddit:, game_pk:, title: nil, post_id: nil)
        super(**subreddit.template_for(type), subreddit:)

        @game_pk = game_pk
        @title = title || default_title
        @post_id = post_id
        @type = type
      end

      def formatted_title = GameThreads::Title.new(@title, game_thread: self).to_s

      def content
        @content ||= @subreddit.bot.api.content @game_pk
      end

      def feed
        @feed ||= @subreddit.bot.api.live_feed @game_pk
      end

      def linescore = feed.linescore

      def boxscore = feed.boxscore

      def game_data = feed.game_data

      def inspect = %(#<#{self.class.name} @game_pk="#{@game_pk}">)

      def postponed? = false

      protected

      def default_title
        playoffs = %w[F D L W].include? game_data.dig('game', 'type')

        if playoffs && @subreddit.options.dig('game_threads', 'title.postseason')
          return @subreddit.options.dig('game_threads', 'title.postseason')
        end

        @subreddit.options.dig('game_threads', 'title')
      end
    end
  end
end

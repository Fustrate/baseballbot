# frozen_string_literal: true

class Baseballbot
  module Templates
    class GameThread < Template
      include Components
      include Game
      include Links
      include Teams
      include Titles

      attr_reader :post_id, :game_pk

      def initialize(type:, subreddit:, game_pk:, title: nil, post_id: nil)
        super(body: subreddit.template_for(type), subreddit:)

        @game_pk = game_pk
        @title = title
        @post_id = post_id
        @type = type
      end

      def content
        @content ||= @subreddit.bot.api.content @game_pk
      end

      def feed
        @feed ||= @subreddit.bot.api.live_feed @game_pk
      end

      def linescore = feed.linescore

      def boxscore = feed.boxscore

      def game_data = feed.game_data

      def inspect = %(#<Baseballbot::Templates::GameThread @game_pk="#{@game_pk}">)

      def postponed? = nil

      # For MarkdownHelpers#player_link until everything is in a reasonable state
      def template = self
    end
  end
end

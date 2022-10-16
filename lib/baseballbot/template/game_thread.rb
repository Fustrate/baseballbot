# frozen_string_literal: true

class Baseballbot
  module Template
    class GameThread < Base
      # This is kept here because of inheritance
      Dir.glob(File.join(File.dirname(__FILE__), 'game_thread', '*.rb')).each { require _1 }

      using TemplateRefinements

      include Template::GameThread::Batters
      include Template::GameThread::Components
      include Template::GameThread::Game
      include Template::GameThread::Highlights
      include Template::GameThread::LineScore
      include Template::GameThread::Links
      include Template::GameThread::Media
      include Template::GameThread::Pitchers
      include Template::GameThread::Postgame
      include Template::GameThread::ScoringPlays
      include Template::GameThread::Teams
      include Template::GameThread::Titles

      attr_reader :post_id, :game_pk

      def initialize(type:, subreddit:, game_pk:, title: nil, post_id: nil)
        super(body: subreddit.template_for(type), subreddit:)

        @game_pk = game_pk
        @title = title
        @post_id = post_id
        @type = type
      end

      def content
        @content ||= @bot.api.content @game_pk
      end

      def feed
        @feed ||= @bot.api.live_feed @game_pk
      end

      def linescore = feed.linescore

      def boxscore = feed.boxscore

      def game_data = feed['gameData']

      def inspect = %(#<Baseballbot::Template::GameThread @game_pk="#{@game_pk}">)

      def player_name(player)
        return 'TBA' unless player

        return player['boxscoreName'] if player['boxscoreName']

        return player['name']['boxscore'] if player['name'] && player['name']['boxscore']

        game_data.dig('players', "ID#{player['person']['id']}", 'boxscoreName')
      end

      def postponed? = nil

      def timestamp = super(over? ? 'Game ended' : 'Updated')
    end
  end
end

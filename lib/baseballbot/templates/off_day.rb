# frozen_string_literal: true

class Baseballbot
  module Templates
    class OffDay < Template
      def initialize(body:, subreddit:, title: '', blocks: nil)
        super(body:, subreddit:, blocks:)

        @title = title
      end

      def formatted_title = Title.new(@title, date: @subreddit.today).to_s
    end
  end
end

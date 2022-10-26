# frozen_string_literal: true

class Baseballbot
  module Templates
    class General < Template
      def initialize(body:, subreddit:, title: '')
        super(body:, subreddit:)

        @title = title
      end

      def inspect = %(#<Baseballbot::Templates::General>)

      def formatted_title
        @formatted_title ||= Time.now.strftime @title
      end
    end
  end
end

# frozen_string_literal: true

class Baseballbot
  module Template
    class General < Base
      def initialize(body:, subreddit:, title: '')
        super(body:, subreddit:)

        @title = title
      end

      def inspect = %(#<Baseballbot::Template::General>)

      def formatted_title
        @formatted_title ||= Time.now.strftime @title
      end
    end
  end
end

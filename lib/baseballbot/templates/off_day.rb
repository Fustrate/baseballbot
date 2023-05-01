# frozen_string_literal: true

class Baseballbot
  module Templates
    class OffDay < Template
      def initialize(body:, subreddit:, title: '')
        super(body:, subreddit:)

        @title = title
      end

      def inspect = %(#<#{self.class.name}>)

      def formatted_title
        @formatted_title ||= @subreddit.today.strftime @title
      end
    end
  end
end

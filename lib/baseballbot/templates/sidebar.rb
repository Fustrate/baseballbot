# frozen_string_literal: true

class Baseballbot
  module Templates
    class Sidebar < Template
      include Sidebars::Components

      def inspect = %(#<#{self.class.name} @subreddit="#{@subreddit.name}">)
    end
  end
end

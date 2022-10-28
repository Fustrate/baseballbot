# frozen_string_literal: true

class Baseballbot
  module Templates
    class Sidebar < Template
      include Sidebars::Components

      def inspect = %(#<Baseballbot::Templates::Sidebar @subreddit="#{@subreddit.name}">)
    end
  end
end

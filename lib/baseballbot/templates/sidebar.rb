# frozen_string_literal: true

Dir.glob(File.join(__dir__, 'sidebars/*.rb')).each { require _1 }

class Baseballbot
  module Templates
    class Sidebar < Template
      include Sidebars::Components

      def inspect = %(#<Baseballbot::Templates::Sidebar @subreddit="#{@subreddit.name}">)
    end
  end
end

# frozen_string_literal: true

class Baseballbot
  module Template
    class Sidebar < Base
      Dir.glob(File.join(File.dirname(__FILE__), 'sidebar', '*.rb')).each { require _1 }

      include Template::Sidebar::Leaders
      include Template::Sidebar::TodaysGames

      def inspect
        %(#<Baseballbot::Template::Sidebar @subreddit="#{@subreddit.name}">)
      end

      def updated_with_link
        "[Updated](/r/baseballbot) #{@subreddit.now.strftime('%-m/%-d at %-I:%M %p %Z')}"
      end

      protected

      def wildcard(wcgb)
        wcgb.to_f * (wcgb[0] == '+' ? -1 : 1)
      end
    end
  end
end

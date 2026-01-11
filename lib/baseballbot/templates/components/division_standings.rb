# frozen_string_literal: true

class Baseballbot
  module Templates
    module Components
      class DivisionStandings < Standings
        include MarkdownHelpers
        include Enumerable
        include Mustache::Enumerable

        def each(&) = teams_in_division(@subreddit.team.division_id).each(&)
      end
    end
  end
end

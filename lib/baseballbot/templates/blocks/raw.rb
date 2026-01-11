# frozen_string_literal: true

class Baseballbot
  module Templates
    module Blocks
      class Raw < Block
        # Raw blocks don't have titles
        def render = interpolate(attributes['markdown'])
      end
    end
  end
end

# __DATA__

# [
#   {
#     type: "division_standings",
#     title: "## {{year}} NL West Standings",
#     columns: ["team_logo", "wins", "losses", "percent", "last_ten"]
#   },
#   {
#     type: "calendar",
#     title: "## {{month_name}} Schedule"
#   },
#   {
#     type: "batting_leaders",
#     title: "## {{year}} Batting Leaders",
#     stats: ["h","xbh","hr","rbi","bb","sb","avg","obp","slg","ops"]
#   },
#   {
#     type: "pitching_leaders",
#     title: "## {{year}} Pitching Leaders",
#     stats: ["w","sv","hld","ip","so","avg","whip","era"]
#   }
# ]

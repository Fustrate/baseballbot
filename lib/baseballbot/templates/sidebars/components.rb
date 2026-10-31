# frozen_string_literal: true

class Baseballbot
  module Templates
    module Sidebars
      module Components
        # These return raw stat data for templates to format, so they can't be wrapped in markers.
        def hitter_stats(...) = Leaders.new(@subreddit).hitter_stats(...)

        def pitcher_stats(...) = Leaders.new(@subreddit).pitcher_stats(...)

        def hitter_stats_table(...)
          <<~MARKDOWN
            [](/baseballbot#batting-leaders)
            #{Leaders.new(@subreddit).hitter_stats_table(...)}
            [](/baseballbot#batting-leaders)
          MARKDOWN
        end

        def pitcher_stats_table(...)
          <<~MARKDOWN
            [](/baseballbot#pitching-leaders)
            #{Leaders.new(@subreddit).pitcher_stats_table(...)}
            [](/baseballbot#pitching-leaders)
          MARKDOWN
        end

        def calendar
          <<~MARKDOWN
            [](/baseballbot#calendar)
            #{Calendar.new(@subreddit)}
            [](/baseballbot#calendar)
          MARKDOWN
        end

        def updated_with_link
          "[Updated](https://baseballbot.io) #{@subreddit.now.strftime('%-m/%-d at %-I:%M %p %Z')}".strip
        end
      end
    end
  end
end

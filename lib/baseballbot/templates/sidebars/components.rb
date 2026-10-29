# frozen_string_literal: true

class Baseballbot
  module Templates
    module Sidebars
      module Components
        def hitter_stats(...) = Leaders.new(@subreddit).hitter_stats(...)

        def pitcher_stats(...) = Leaders.new(@subreddit).pitcher_stats(...)

        def hitter_stats_table(...) = Leaders.new(@subreddit).hitter_stats_table(...)

        def pitcher_stats_table(...) = Leaders.new(@subreddit).pitcher_stats_table(...)

        def calendar = Calendar.new(@subreddit)

        def updated_with_link
          "[Updated](https://baseballbot.io) #{@subreddit.now.strftime('%-m/%-d at %-I:%M %p %Z')}".strip
        end
      end
    end
  end
end

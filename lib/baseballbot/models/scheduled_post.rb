# frozen_string_literal: true

class Baseballbot
  module Models
    class ScheduledPost < Sequel::Model(:scheduled_posts)
      many_to_one :subreddit
    end
  end
end

# frozen_string_literal: true

class Baseballbot
  module Models
    class SubredditsUser < Sequel::Model(:subreddits_users)
      many_to_one :subreddit
      many_to_one :user
    end
  end
end

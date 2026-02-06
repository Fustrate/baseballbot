# frozen_string_literal: true

class Baseballbot
  module Models
    class User < Sequel::Model(:users)
      one_to_many :subreddits_users
      many_to_many :subreddits, join_table: :subreddits_users, left_key: :user_id, right_key: :subreddit_id
    end
  end
end

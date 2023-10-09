# frozen_string_literal: true

class Baseballbot
  module Models
    class Account < Sequel::Model(:accounts)
      one_to_many :subreddits

      def access
        Redd::Models::Access.new(
          access_token:,
          refresh_token:,
          scope:,
          # Remove 30 seconds so we don't run into invalid credentials
          expires_at: expires_at - 30,
          expires_in: expires_at - Time.now
        )
      end
    end
  end
end

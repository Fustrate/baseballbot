# frozen_string_literal: true

class Baseballbot
  module Models
    class Template < Sequel::Model(:templates)
      many_to_one :subreddit
    end
  end
end

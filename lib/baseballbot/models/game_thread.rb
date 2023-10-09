# frozen_string_literal: true

class Baseballbot
  module Models
    class GameThread < Sequel::Model(:game_threads)
      many_to_one :subreddit
    end
  end
end

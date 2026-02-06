# frozen_string_literal: true

class Baseballbot
  module Models
    class Template < Sequel::Model(:templates)
      many_to_one :subreddit

      dataset_module do
        def for_subreddit(subreddit_id) = where(subreddit_id:)

        def of_type(type) = where(type:)
      end
    end
  end
end

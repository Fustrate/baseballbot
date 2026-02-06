# frozen_string_literal: true

class Baseballbot
  module Models
    class GameThread < Sequel::Model(:game_threads)
      one_to_many :edits, key: :editable_id, reciprocal: :game_thread
      many_to_one :subreddit

      dataset_module do
        def with_subreddit = join(:subreddits, id: :subreddit_id)

        def with_subreddit_name
          with_subreddit
            .select_all(:game_threads)
            .select_append(Sequel[:subreddits][:name])
        end

        def posted = where(status: 'Posted')

        def unposted = where(status: %w[Pregame Future])

        def postable = where { post_at <= Sequel.lit('NOW()') }

        def started = where { starts_at <= Sequel.lit('NOW()') }

        def with_game_threads_enabled
          where(Sequel.lit("subreddits.options['game_threads']['enabled']::boolean IS TRUE"))
        end
      end
    end
  end
end

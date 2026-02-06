# frozen_string_literal: true

class Baseballbot
  module Pregames
    CONDITION = <<~SQL
      CASE WHEN substr(subreddits.options#>>'{pregame,post_at}', 1, 1) = '-' THEN
        (starts_at::timestamp + (CONCAT(subreddits.options#>>'{pregame,post_at}', ' hours'))::interval) < NOW()
      ELSE
        (DATE(starts_at) + (subreddits.options#>>'{pregame,post_at}')::interval) < NOW() AT TIME ZONE (subreddits.options->>'timezone')
      END
    SQL

    def post_pregame_threads!(names: [])
      names = names.map(&:downcase)

      unposted_pregames
        .each { post_pregame_thread!(it) if names.empty? || names.include?(it[:name].downcase) }
    end

    def post_pregame_thread!(row)
      Honeybadger.context(row)

      Baseballbot::Posts::Pregame.new(row, subreddit: name_to_subreddit(row[:name])).create!
    rescue => e
      Honeybadger.notify(e)
    end

    def unposted_pregames
      Baseballbot::Models::GameThread
        .with_subreddit_name
        .where(status: 'Future')
        .where(Sequel.lit("subreddits.options['pregame']['enabled']::boolean IS TRUE"))
        .where(Sequel.lit(CONDITION))
        .order(:post_at, :game_pk)
        .all
    end
  end
end

# frozen_string_literal: true

class Baseballbot
  module Pregames
    UNPOSTED_PREGAMES_QUERY = <<~SQL
      SELECT game_threads.id, game_pk, subreddits.name
      FROM game_threads
      JOIN subreddits ON (subreddits.id = subreddit_id)
      WHERE status = 'Future'
        AND subreddits.options['pregame']['enabled']::boolean IS TRUE
        AND (
          CASE WHEN substr(subreddits.options#>>'{pregame,post_at}', 1, 1) = '-' THEN
            (starts_at::timestamp + (CONCAT(subreddits.options#>>'{pregame,post_at}', ' hours'))::interval) < NOW()
          ELSE
            (DATE(starts_at) + (subreddits.options#>>'{pregame,post_at}')::interval) < NOW() AT TIME ZONE (subreddits.options->>'timezone')
          END)
      ORDER BY post_at ASC, game_pk ASC
    SQL

    def post_pregame_threads!(names: [])
      names = names.map(&:downcase)

      db.exec(UNPOSTED_PREGAMES_QUERY)
        .each { post_pregame_thread!(_1) if names.empty? || names.include?(_1['name'].downcase) }
    end

    def post_pregame_thread!(row)
      Honeybadger.context(row)

      Baseballbot::Posts::Pregame.new(row, subreddit: name_to_subreddit(row['name'])).create!
    rescue => e
      Honeybadger.notify(e)
    end
  end
end

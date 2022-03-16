# frozen_string_literal: true

class Baseballbot
  module GameThreads
    UNPOSTED_GAME_THREADS_QUERY = <<~SQL
      SELECT game_threads.id, game_pk, subreddits.name, title, type
      FROM game_threads
      JOIN subreddits ON (subreddits.id = subreddit_id)
      WHERE status IN ('Pregame', 'Future')
        AND post_at <= NOW()
        AND options['game_threads']['enabled']::boolean IS TRUE
      ORDER BY post_at ASC, game_pk ASC
    SQL

    ACTIVE_GAME_THREADS_QUERY = <<~SQL
      SELECT game_threads.id, game_pk, subreddits.name, post_id, type
      FROM game_threads
      JOIN subreddits ON (subreddits.id = subreddit_id)
      WHERE status = 'Posted'
        AND starts_at <= NOW()
      ORDER BY post_id ASC
    SQL

    POSTED_GAME_THREADS_QUERY = <<~SQL
      SELECT game_threads.id, game_pk, subreddits.name, post_id, type
      FROM game_threads
      JOIN subreddits ON (subreddits.id = subreddit_id)
      WHERE status = 'Posted'
      ORDER BY post_id ASC
    SQL

    def post_game_threads!(names: [])
      unposted_game_threads(names).each do |row|
        build_game_thread(row).create!
      rescue => e
        logger.error e.message

        Honeybadger.notify(e, context: row)
      end
    end

    def update_game_threads!(names: [])
      game_threads_to_update(names).each do |row|
        build_game_thread(row).update!
      rescue => e
        logger.error e.message

        Honeybadger.notify(e, context: row)
      end
    end

    def build_game_thread(row)
      Honeybadger.context(subreddit: row['name'])

      Baseballbot::Posts::GameThread.new(row, subreddit: name_to_subreddit(row['name']))
    end

    # Every 10 minutes, update every game thread no matter what.
    def game_threads_to_update(names)
      names = names.map(&:downcase)

      return posted_game_threads if names.include?('posted')

      active_game_threads.select { names.empty? || names.include?(_1['name'].downcase) }
    end

    def active_game_threads = db.exec(ACTIVE_GAME_THREADS_QUERY)

    def posted_game_threads = db.exec(POSTED_GAME_THREADS_QUERY)

    def unposted_game_threads(names)
      names = names.map(&:downcase)

      db.exec(UNPOSTED_GAME_THREADS_QUERY)
        .select { names.empty? || names.include?(_1['name'].downcase) }
    end
  end
end

# frozen_string_literal: true

class Baseballbot
  module GameThreads
    GAME_THREADS_ENABLED = Sequel.lit("subreddits.options['game_threads']['enabled']::boolean IS TRUE")

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
      Honeybadger.context(subreddit: row[:name])

      Baseballbot::Posts::GameThread.new(row, subreddit: name_to_subreddit(row[:name]))
    end

    # Every 10 minutes, update every game thread no matter what.
    def game_threads_to_update(names)
      names = names.map(&:downcase)

      return posted_game_threads if names.include?('posted')

      active_game_threads.select { names.empty? || names.include?(it[:name].downcase) }
    end

    def active_game_threads
      sequel[:game_threads]
        .join(:subreddits, id: :subreddit_id)
        .where(status: 'Posted')
        .where { starts_at <= Sequel.lit('NOW()') }
        .order(:post_id)
        .all
    end

    def posted_game_threads
      sequel[:game_threads]
        .join(:subreddits, id: :subreddit_id)
        .where(status: 'Posted')
        .order(:post_id)
        .all
    end

    def unposted_game_threads(names)
      names = names.map(&:downcase)

      sequel[:game_threads]
        .join(:subreddits, id: :subreddit_id)
        .where(status: %w[Pregame Future])
        .where { post_at <= Sequel.lit('NOW()') }
        .where(GAME_THREADS_ENABLED)
        .order(:post_at, :game_pk)
        .all
        .select { names.empty? || names.include?(it[:name].downcase) }
    end
  end
end

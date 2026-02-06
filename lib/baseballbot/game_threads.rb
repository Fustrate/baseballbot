# frozen_string_literal: true

class Baseballbot
  module GameThreads
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
      Honeybadger.context(game_thread_id: row.id, subreddit: row.subreddit.name)

      Baseballbot::Posts::GameThread.new(row, subreddit: name_to_subreddit(row.subreddit.name))
    end

    # Every 10 minutes, update every game thread no matter what.
    def game_threads_to_update(names)
      names = names.map(&:downcase)

      return posted_game_threads if names.include?('posted')

      active_game_threads.select { names.empty? || names.include?(it[:name].downcase) }
    end

    def active_game_threads
      Baseballbot::Models::GameThread
        .with_subreddit_name
        .posted
        .started
        .order(:post_id)
        .all
    end

    def posted_game_threads
      Baseballbot::Models::GameThread
        .with_subreddit_name
        .posted
        .order(:post_id)
        .all
    end

    def unposted_game_threads(names)
      names = names.map(&:downcase)

      Baseballbot::Models::GameThread
        .with_subreddit_name
        .unposted
        .postable
        .with_game_threads_enabled
        .order(:post_at, :game_pk)
        .all
        .select { names.empty? || names.include?(it[:name].downcase) }
    end
  end
end

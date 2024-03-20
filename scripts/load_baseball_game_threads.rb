# frozen_string_literal: true

require_relative 'game_thread_loader'

# /r/baseball is running a game thread for all games this season... for now.
class BaseballGameThreadLoader < GameThreadLoader
  SUBREDDIT_ID = 15

  POST_AT_QUERY = <<~SQL.freeze
    SELECT options#>>'{game_threads,post_at}' AS post_at
    FROM subreddits
    WHERE id = #{SUBREDDIT_ID}
  SQL

  def initialize
    super(date: Date.today)
  end

  def add_game(game)
    starts_at = Time.parse(game['gameDate']) + @utc_offset

    insert_game(SUBREDDIT_ID, game, post_at.call(starts_at), starts_at)
  end

  def post_at
    @post_at ||= Baseballbot::Utility.adjust_time_proc(db.exec(POST_AT_QUERY)[0]['post_at'])
  end
end

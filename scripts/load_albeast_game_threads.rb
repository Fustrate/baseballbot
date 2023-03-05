# frozen_string_literal: true

require_relative 'load_game_threads'

# Add all AL East interdivision games to /r/albeast's schedule
class ALEastGameThreadLoader < GameThreadLoader
  SUBREDDIT_ID = 35
  DIVISION_ID = 201

  POST_AT_QUERY = <<~SQL.freeze
    SELECT options#>>'{game_threads,post_at}' AS post_at
    FROM subreddits
    WHERE id = #{SUBREDDIT_ID}
  SQL

  def add_game?(game)
    super(game) &&
      game.dig('teams', 'away', 'team', 'division', 'id') == DIVISION_ID &&
      game.dig('teams', 'home', 'team', 'division', 'id') == DIVISION_ID
  end

  def add_game(game)
    starts_at = Time.parse(game['gameDate']) + @utc_offset

    insert_game(SUBREDDIT_ID, game, post_at.call(starts_at), starts_at)
  end

  def post_at
    @post_at ||= Baseballbot::Utility.adjust_time_proc(db.exec(POST_AT_QUERY)[0]['post_at'])
  end
end

ALEastGameThreadLoader.new.run

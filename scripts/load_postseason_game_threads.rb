# frozen_string_literal: true

require_relative 'default_bot'

# Load all postseason game threads for /r/baseball
class PostseasonGameLoader < DefaultBot
  R_BASEBALL = 15

  # TODO: This is a bad fix - figure it out the right way
  HOUR_OFFSET = 8

  def initialize
    super(purpose: 'Postseason /r/baseball Game Thread Loader')

    @attempts = @failures = 0

    @utc_offset = Time.now.utc_offset
  end

  def run
    api.schedule(type: :postseason, hydrate: 'team,metadata,seriesStatus')['dates'].each do |date|
      date['games'].each { process_game(it) }
    end

    puts "Added #{@attempts - @failures} of #{@attempts}"
  end

  protected

  def process_game(game)
    return unless add_game_to_schedule?(game)

    starts_at = Time.parse(game['gameDate']) + @utc_offset

    return if starts_at < Time.now

    insert_game game, starts_at, starts_at - 3600, baseball_subreddit_title, R_BASEBALL

    insert_team_game game, starts_at
  end

  def team_subreddits
    @team_subreddits ||= team_subreddits_data.group_by { it['team_id'] }
  end

  def team_subreddits_data
    db.exec(<<~SQL)
      SELECT id, team_id, options#>>'{game_threads,post_at}' AS post_at,
        COALESCE(options#>>'{game_threads,title,postseason}', options#>>'{game_threads,title,default}') AS title
      FROM subreddits
      WHERE options['game_threads']['enabled']::boolean IS TRUE
        AND team_id IS NOT NULL
    SQL
  end

  def insert_team_game(game, starts_at)
    %w[away home].each do |flag|
      subreddits = team_subreddits[game.dig('teams', flag, 'team', 'id').to_s]

      next unless subreddits

      subreddits.each do |row|
        post_at = Baseballbot::Utility.adjust_time_proc(row['post_at']).call starts_at

        insert_game game, starts_at, post_at, row['title'], row['id']
      end
    end
  end

  def add_game_to_schedule?(game)
    # If the team is undetermined, their division will be blank
    !game.dig('status', 'startTimeTBD') &&
      game.dig('teams', 'away', 'team', 'division') &&
      game.dig('teams', 'home', 'team', 'division') &&
      !game.dig('seriesStatus', 'isOver') &&
      game['ifNecessary'] != 'Y'
  end

  def insert_game(game, starts_at, post_at, title, subreddit_id)
    @attempts += 1

    data = row_data(game, starts_at, post_at, title, subreddit_id)

    db.exec_params(<<~SQL, data.values)
      INSERT INTO game_threads (#{data.keys.join(', ')})
      VALUES (#{(1..data.size).map { "$#{it}" }.join(', ')})
    SQL
  rescue PG::UniqueViolation
    @failures += 1
  end

  def row_data(game, starts_at, post_at, title, subreddit_id)
    {
      game_pk: game['gamePk'],
      post_at: post_at.strftime('%F %T'),
      starts_at: starts_at.strftime('%F %T'),
      subreddit_id:,
      status: 'Future',
      title:
    }
  end

  def baseball_subreddit_title
    @baseball_subreddit_title ||= db.exec(<<~SQL).first['title']
      SELECT
        options#>>'{game_threads,title,postseason}' AS title
      FROM subreddits
      WHERE id = #{R_BASEBALL}
    SQL
  end
end

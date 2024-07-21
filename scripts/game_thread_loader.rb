# frozen_string_literal: true

require_relative 'default_bot'

class GameThreadLoader < DefaultBot
  INSERT_GAME_THREAD = <<~SQL
    INSERT INTO game_threads (post_at, starts_at, subreddit_id, game_pk, status, title)
    VALUES ($1, $2, $3, $4, 'Future', $5)
  SQL

  UPDATE_GAME_THREAD = <<~SQL
    UPDATE game_threads
    SET post_at = $1, starts_at = $2, updated_at = $3, title = $6
    WHERE subreddit_id = $4
      AND game_pk = $5
      AND (starts_at != $2 OR post_at != $1)
      AND date_trunc('day', starts_at) = date_trunc('day', $2)
  SQL

  ENABLED_SUBREDDITS = <<~SQL
    SELECT id, name, team_id, options#>>'{game_threads,post_at}' AS post_at
    FROM subreddits
    WHERE team_id IS NOT NULL
    AND options['game_threads']['enabled']::boolean IS TRUE
  SQL

  def initialize(date: nil, subreddits: [])
    super(purpose: 'Game Thread Loader', account: 'BaseballBot')

    @created = @updated = 0
    @date = date || Date.today

    # Don't load games that aren't at least from today
    @start_date = Date.today.strftime('%F')

    process_subreddit_names(subreddits.map(&:downcase))

    @utc_offset = Time.now.utc_offset
  end

  def run
    month_schedule['dates'].each do |date|
      next if date['date'] < @start_date

      date['games'].each do |game|
        add_game(game) if add_game?(game)
      end
    end

    {
      created: @created,
      updated: @updated
    }
  end

  protected

  def process_subreddit_names(subreddit_names)
    @subreddit_names = subreddit_names

    # There could be multiple subreddits for a single team, so a normal hash isn't useful
    @subs_to_add = Hash.new { |h, k| h[k] = [] }

    db.exec(ENABLED_SUBREDDITS).each do |row|
      next unless include_subreddit?(row['name'])

      @subs_to_add[row['team_id'].to_i] << {
        id: row['id'].to_i,
        post_at: Baseballbot::Utility.adjust_time_proc(row['post_at'])
      }
    end
  end

  def add_game?(game) = !game.dig('status', 'startTimeTBD')

  def include_subreddit?(name) = @subreddit_names.empty? || @subreddit_names.include?(name.downcase)

  def month_schedule
    api.schedule(
      startDate: @date.strftime('%F'),
      endDate: (@date + 30).strftime('%F'),
      eventTypes: 'primary',
      scheduleTypes: 'games',
      hydrate: 'team,game(content(media(epg))),broadcasts(all)',
      gameType: 'R'
    )
  end

  def add_game(game)
    starts_at = Time.parse(game['gameDate']) + @utc_offset

    %w[away home].each do |home_or_away|
      @subs_to_add[game.dig('teams', home_or_away, 'team', 'id')].each do |team_info|
        insert_game(team_info[:id], game, team_info[:post_at].call(starts_at), starts_at)
      end
    end
  end

  def insert_game(subreddit_id, game, post_at, starts_at, title = '')
    data = row_data(game, starts_at, post_at, subreddit_id, title)

    db.exec_params INSERT_GAME_THREAD, data.values_at(:post_at, :starts_at, :subreddit_id, :game_pk, :title)

    @created += 1
  rescue PG::UniqueViolation
    update_game(data)
  end

  def row_data(game, starts_at, post_at, subreddit_id, title)
    {
      post_at: post_at.strftime('%F %T'),
      starts_at: starts_at.strftime('%F %T'),
      updated_at: Time.now.strftime('%F %T'),
      subreddit_id:,
      game_pk: game['gamePk'].to_i,
      title:
    }
  end

  def update_game(data)
    @updated += db
      .exec_params(
        UPDATE_GAME_THREAD,
        data.values_at(:post_at, :starts_at, :updated_at, :subreddit_id, :game_pk, :title)
      )
      .cmd_tuples
  end
end

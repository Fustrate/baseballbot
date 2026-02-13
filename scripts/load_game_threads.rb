# frozen_string_literal: true

require_relative 'default_bot'

class LoadGameThreads < DefaultBot
  def initialize(date: nil, subreddits: [])
    super(purpose: 'Game Thread Loader', bot: 'BaseballBot')

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

    enabled_subreddits.each do |row|
      next unless include_subreddit?(row[:name])

      @subs_to_add[row[:team_id].to_i] << {
        id: row[:id].to_i,
        post_at: Baseballbot::Utility.adjust_time_proc(row[:post_at])
      }
    end
  end

  def enabled_subreddits
    Baseballbot::Models::Subreddit
      .where(Sequel.lit("team_id IS NOT NULL AND options['game_threads']['enabled']::boolean IS TRUE"))
      .select(:id, :name, :team_id, Sequel.as(Sequel.lit("options#>>'{game_threads,post_at}'"), :post_at))
  end

  def add_game?(game) = !game.dig('status', 'startTimeTBD')

  def include_subreddit?(name) = @subreddit_names.empty? || @subreddit_names.include?(name.downcase)

  def month_schedule
    api.schedule(
      startDate: @date.strftime('%F'),
      endDate: (@date + 30).strftime('%F'),
      calendarTypes: 'PRIMARY',
      scheduleTypes: 'GAMESCHEDULE',
      hydrate: 'team,game(content(media(epg))),broadcasts(all)',
      gameType: 'R,S'
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

  def insert_game(subreddit_id, game, post_at, starts_at, title = nil)
    data = row_data(game, starts_at, post_at, subreddit_id, title)

    Baseballbot::Models::GameThread.insert(data)

    @created += 1
  rescue PG::UniqueViolation, Sequel::UniqueConstraintViolation
    update_game(data)
  end

  def row_data(game, starts_at, post_at, subreddit_id, title)
    {
      post_at: post_at.strftime('%F %T'),
      starts_at: starts_at.strftime('%F %T'),
      updated_at: Time.now.strftime('%F %T'),
      subreddit_id:,
      game_pk: game['gamePk'].to_i,
      title:,
      status: 'Future'
    }
  end

  def update_game(data)
    @updated += Baseballbot::Models::GameThread
      .where(
        subreddit_id: data[:subreddit_id],
        game_pk: data[:game_pk]
      )
      .where(Sequel.lit('starts_at != ? OR post_at != ?', data[:starts_at], data[:post_at]))
      .where(Sequel.lit("date_trunc('day', starts_at) = date_trunc('day', ?)", data[:starts_at]))
      .update(data.slice(:post_at, :starts_at, :updated_at, :title))
  end
end

# frozen_string_literal: true

require_relative 'baseballbot'

# Add the ESPN game of the week to /r/baseball's schedule
class SundayGameThreadLoader
  R_BASEBALL_ID = 15

  def initialize
    @attempts = @failures = 0

    @bot = Baseballbot.new

    @utc_offset = Time.now.utc_offset
  end

  def run
    next_sunday = Time.now + (86_400 * ((7 - Time.now.wday) % 7))

    (0..4).each { load_espn_game(next_sunday + (_1 * 604_800)) }

    puts "Added #{@attempts - @failures} of #{@attempts}"
  end

  protected

  def load_espn_game(date)
    sunday_games(date).each do |game|
      # Game time is not yet set or something is TBD
      next unless game['gameType'] == 'R' && espn_game?(game)

      starts_at = Time.parse(game['gameDate']) + @utc_offset

      insert_game game, starts_at if starts_at > Time.now
    end
  end

  def sunday_games(date)
    @bot.api.schedule(
      sportId: 1,
      date: date.strftime('%m/%d/%Y'),
      hydrate: 'game(content(media(epg)))'
    ).dig('dates', 0, 'games')
  end

  def espn_game?(game)
    game.dig('content', 'media', 'epg')
      .find { _1['title'] == 'MLBTV' }
      &.dig('items')
      &.any? { _1['callLetters'] == 'ESPN' }
  end

  def insert_game(game, starts_at)
    @attempts += 1

    data = game_data(game, starts_at)

    @bot.db.exec_params(<<~SQL, data.values)
      INSERT INTO game_threads (#{data.keys.join(', ')})
      VALUES (#{(1..data.size).map { "$#{_1}" }.join(', ')})
    SQL

    puts "+ #{game['gamePk']}"
  rescue PG::UniqueViolation
    failed_to_insert(game)
  end

  def game_data(game, starts_at)
    {
      game_pk: game['gamePk'],
      post_at: (starts_at - 3600).strftime('%F %T'),
      starts_at: starts_at.strftime('%F %T'),
      status: 'Future',
      subreddit_id: R_BASEBALL_ID
    }
  end

  def failed_to_insert(game)
    @failures += 1

    puts "- #{game['gamePk']}"
  end
end

SundayGameThreadLoader.new.run

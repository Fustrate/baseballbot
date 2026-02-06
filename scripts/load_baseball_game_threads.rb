# frozen_string_literal: true

require_relative 'game_thread_loader'

# /r/baseball runs game threads for national broadcasts and MLB.TV's free game of the day.
class BaseballGameThreadLoader < GameThreadLoader
  SUBREDDIT_ID = 15

  TITLE = '%<type>s Game of the Day {{month}}/{{day}} ⚾ {{away_name}} ({{away_record}}) @ {{home_name}} ' \
          '({{home_record}}) {{start_time_et}}'

  NATIONAL_CALLSIGNS = ['ESPN'].freeze

  def initialize
    super(date: Date.today)
  end

  def add_game(game)
    title = national_game_title(game)

    return unless title

    starts_at = Time.parse(game['gameDate']) + @utc_offset

    insert_game(SUBREDDIT_ID, game, post_at.call(starts_at), starts_at, title)
  end

  def post_at
    @post_at ||= Baseballbot::Utility.adjust_time_proc(
      Baseballbot::Models::Subreddit
        .where(id: SUBREDDIT_ID)
        .select(Sequel.as('options#>>\'{game_threads,post_at}\'', :post_at))
        .first[:post_at]
    )
  end

  def national_game_title(game)
    national_broadcast = game['broadcasts'].find { it['isNational'] && NATIONAL_CALLSIGNS.include?(it['callSign']) }

    return format(TITLE, type: national_broadcast['callSign']) if national_broadcast

    return unless game['broadcasts'].any? { it['freeGame'] }

    format(TITLE, type: 'Free')
  end
end

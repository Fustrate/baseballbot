# frozen_string_literal: true

require_relative 'default_bot'

# Known bug: if there are dueling no hitters, only the home team will get a post since the database has a uniqueness
# constraint on subreddit/game_pk/type.
class NoHitterBot < DefaultBot
  MIN_INNINGS = 6
  SUBREDDIT_NAME = 'baseball'

  # Depending on how far into a no-hit game we are, skip checks for a while
  WAIT_TIMES = [0, 3600, 1800, 900, 600, 300, 30].freeze

  def initialize
    super(purpose: 'No Hitter Bot')

    use_account name_to_subreddit(SUBREDDIT_NAME).account.name
  end

  def post_no_hitters!
    return unless perform_check?

    # Default to checking again in 30 minutes
    @next_check = [Time.now + 1800]

    schedule = api.schedule(
      date: Time.now.strftime('%m/%d/%Y'),
      hydrate: 'game,linescore,flags,team',
      sportId: 1
    )

    schedule.dig('dates', 0, 'games').each { process_game(_1) }

    redis.set 'next_no_hitter_check', @next_check.min.strftime('%F %T')
  end

  protected

  def perform_check?
    return true if ENV.fetch('FORCE', nil)

    value = redis.get 'next_no_hitter_check'

    !value || Time.parse(value) < Time.now
  end

  def subreddit
    @subreddit ||= name_to_subreddit(SUBREDDIT_NAME)
  end

  def process_game(game)
    # return unless no_hitter?(game)

    inning = game.dig('linescore', 'currentInning')
    half = game.dig('linescore', 'inningHalf')

    # Game hasn't started yet
    return unless inning

    post_thread!(game, 'home') if post_home_thread?(game, inning, half)
    post_thread!(game, 'away') if post_away_thread?(game, inning, half)
  end

  def post_home_thread?(game, inning, half)
    !already_posted?(game['gamePk']) && away_team_being_no_hit?(game, inning, half)
  end

  def post_away_thread?(game, inning, half)
    !already_posted?(game['gamePk']) && home_team_being_no_hit?(game, inning, half)
  end

  # Checking for a perfect game is likely redundant
  def no_hitter?(game)
    # The flag doesn't get set until 6 innings are done
    MIN_INNINGS < 6 || game.dig('flags', 'noHitter') || game.dig('flags', 'perfectGame')
  end

  # Check the away team if it's after the top of the target inning or later
  def away_team_being_no_hit?(game, inning, half)
    return unless game.dig('linescore', 'teams', 'away', 'hits').zero?

    return true if inning > MIN_INNINGS || (inning == MIN_INNINGS && half != 'Top')

    @next_check << (Time.now + WAIT_TIMES.last(MIN_INNINGS + 1)[inning])

    false
  end

  # Check the home team if it's the end of the target inning or later
  def home_team_being_no_hit?(game, inning, half)
    return unless game.dig('linescore', 'teams', 'home', 'hits').zero?

    return true if inning > MIN_INNINGS || (inning == MIN_INNINGS && half == 'End')

    @next_check << (Time.now + WAIT_TIMES.last(MIN_INNINGS + 1)[inning])

    false
  end

  def no_hitter_template(game, flag) = Baseballbot::Templates::NoHitter.new(subreddit:, game_pk: game['gamePk'], flag:)

  def post_thread!(game, flag)
    template = no_hitter_template(game, flag)

    submission = subreddit.submit title: template.formatted_title, text: template.evaluated_body

    insert_game_thread!(submission, game)

    submission.set_suggested_sort 'new'
  end

  def already_posted?(game_pk)
    db.exec_params(<<~SQL, [subreddit.id, game_pk, 'no_hitter']).any?
      SELECT 1 FROM game_threads WHERE subreddit_id = $1 AND game_pk = $2 AND type = $3
    SQL
  end

  def insert_game_thread!(submission, game)
    data = [
      Time.now.strftime('%F %T'),
      subreddit.id,
      game['gamePk'],
      submission.id,
      submission.title
    ]

    db.exec_params(<<~SQL, data)
      INSERT INTO game_threads (post_at, starts_at, subreddit_id, game_pk, post_id, title, status, type)
      VALUES ($1, $1, $2, $3, $4, $5, 'Posted', 'no_hitter')
    SQL
  end
end

NoHitterBot.new.post_no_hitters!

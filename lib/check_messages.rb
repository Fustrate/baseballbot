# frozen_string_literal: true

require_relative 'default_bot'

class CheckMessages
  TITLE = /(?:game ?(?:thread|chat|day)|gdt)/i
  LINK = %r{(?:redd\.it|/comments|reddit\.com)/([a-z0-9]{6})}i
  GAME_PK = %r{(?:gamePk=|gameday/)(\d{6,})}i

  def initialize
    @bot = DefaultBot.create(purpose: 'Messages', account: 'BaseballBot')
  end

  def run!(retry_on_failure: true)
    unread_messages.each { process_message(_1) }
  rescue Redd::Errors::APIError
    return unless retry_on_failure

    puts 'Service unavailable: waiting 30 seconds to retry.'

    sleep 30

    run!(retry_on_failure: false)
  rescue => e
    Honeybadger.notify(e)
  end

  protected

  def unread_messages = @bot.session.my_messages(category: 'unread', mark: false, limit: 10) || []

  def process_message(message)
    post_id = extract_post_id(message)

    return unless post_id

    submission = @bot.session.from_ids("t3_#{post_id}")&.first

    return unless submission

    subreddit_id = @bot.name_to_subreddit(submission.subreddit.display_name.downcase).id

    game_pk = Regexp.last_match[1] if submission.selftext =~ GAME_PK

    add_game_thread!(game_pk, submission, subreddit_id, post_id)

    message.mark_as_read
  end

  def extract_post_id(message) = (Regexp.last_match[1] if message.subject =~ TITLE && message.body =~ LINK)

  def game_thread_data(game_pk, submission, subreddit_id, post_id)
    {
      subreddit_id:,
      post_at: Time.now,
      starts_at: Time.now,
      title: submission.title,
      game_pk:,
      status: 'External',
      post_id:
    }
  end

  def add_game_thread!(game_pk, submission, subreddit_id, post_id)
    return unless game_pk && submission && subreddit_id && post_id

    data = game_thread_data(game_pk, submission, subreddit_id, post_id)

    @bot.db.exec_params(<<~SQL, data.values)
      INSERT INTO game_threads (#{data.keys.join(', ')})
      VALUES ($#{(1..data.size).to_a.join(', $')})
    SQL
  rescue PG::UniqueViolation
    # Do nothing
  end
end

CheckMessages.new.run!

# frozen_string_literal: true

require_relative 'default_bot'

class AroundTheHorn < DefaultBot
  ATH_SUBREDDIT = 'baseball'

  # Make a new post every morning at 4:30 Pacific
  POST_AT = 4.5 * 3_600

  class ATHTemplate < Baseballbot::Templates::Sidebar
    include Baseballbot::MarkdownHelpers

    TODAYS_GAMES = <<~MUSTACHE
      {{yesterday_link}}
    MUSTACHE

    def initialize(subreddit:) = super(body: TODAYS_GAMES, subreddit:)

    def yesterday_link
      yesterday_id = @subreddit.bot.redis.hget('around_the_horn', (@subreddit.now - (3_600 * 27)).strftime('%F'))

      yesterday_id ? "[Yesterday's ATH](/comments/#{yesterday_id})" : ''
    end
  end

  def initialize
    super(purpose: 'Around the Horn', bot: 'DodgerBot')

    @subreddit = name_to_subreddit(ATH_SUBREDDIT)

    # Keep updating the same thread until 3 AM Pacific
    @date = @subreddit.now - POST_AT
  end

  def run
    return if todays_submission_id

    submission = @subreddit.submit(title: post_title, text: initial_body)

    submission.make_sticky(slot: 1)
    submission.set_suggested_sort 'new'

    redis.hset 'around_the_horn', @date.strftime('%F'), submission.id
  end

  protected

  def todays_submission_id = redis.hget('around_the_horn', @date.strftime('%F'))

  def post_title = @date.strftime('[General Discussion] Around the Horn & Game Thread Index - %-m/%-d/%y')

  def initial_body = @subreddit.subreddit.wiki_page('ath').content_md.split(/\r?\n-{3,}\r?\n/)[1].strip
end

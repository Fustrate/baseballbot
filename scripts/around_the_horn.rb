# frozen_string_literal: true

require_relative 'default_bot'

class AroundTheHorn < DefaultBot
  ATH_SUBREDDIT = 'baseball'

  # Make a new post every morning at 4:30 Pacific
  POST_AT = 4.5 * 3_600

  class ATHTemplate < Baseballbot::Templates::Sidebar
    include Baseballbot::MarkdownHelpers

    TODAYS_GAMES = <<~MUSTACHE
      {{todays_games_section}}

      {{yesterday_link}}
    MUSTACHE

    def initialize(subreddit:) = super(body: TODAYS_GAMES, subreddit:)

    def todays_games_section
      @todays_games = Baseballbot::Templates::Sidebars::Components::TodaysGames.new(@subreddit, links: :direct).to_a

      return '' if @todays_games.none?

      <<~MARKDOWN
        # #{ath_games_header}

        #{ath_games_table}

        ^(★)Game Thread. All game times are Eastern. #{updated_with_link}
      MARKDOWN
    end

    def ath_games_header = "#{(@subreddit.now - POST_AT).strftime('%A')}'s Games"

    def ath_games_table
      table(
        headers: ['Away', ['Score', :center], 'Home', ['Score', :center], ['Status', :center], 'National'],
        rows: @todays_games.map { todays_games_row(_1) }
      )
    end

    def yesterday_link
      yesterday_id = @subreddit.bot.redis.hget('around_the_horn', (@subreddit.now - (3_600 * 27)).strftime('%F'))

      yesterday_id ? "[Yesterday's ATH](/#{yesterday_id})" : ''
    end

    protected

    def todays_games_row(game)
      [
        game[:away][:link],
        game[:away][:score],
        game[:home][:link],
        game[:home][:score],
        game[:status],
        game[:national] || ' '
      ]
    end
  end

  def initialize
    super(purpose: 'Around the Horn', account: 'BaseballBot')

    @subreddit = name_to_subreddit(ATH_SUBREDDIT)

    # Keep updating the same thread until 3 AM Pacific
    @date = @subreddit.now - POST_AT
  end

  def run
    submission_id = todays_submission_id

    submission_id ? update!(submission_id) : post!
  end

  protected

  def update!(submission_id)
    submission = @subreddit.load_submission id: submission_id

    @subreddit.edit id: submission_id, body: update_todays_games_in(submission)
  end

  def post!
    submission = @subreddit.submit(title: post_title, text: update_todays_games_in(initial_body))

    submission.make_sticky(slot: 1)
    submission.set_suggested_sort 'new'

    redis.hset 'around_the_horn', @date.strftime('%F'), submission.id
  end

  def todays_submission_id = redis.hget('around_the_horn', @date.strftime('%F'))

  def post_title = @date.strftime('[General Discussion] Around the Horn - %-m/%-d/%y')

  def initial_body = @subreddit.subreddit.wiki_page('ath').content_md.split(/\r?\n-{3,}\r?\n/)[1].strip

  def update_todays_games_in(text)
    ATHTemplate.new(subreddit: @subreddit).replace_in(text, delimiter: '[](/todays_games)')
  end
end

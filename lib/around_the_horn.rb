# frozen_string_literal: true

require_relative 'default_bot'

class AroundTheHorn < DefaultBot
  class ATHTemplate < Baseballbot::Templates::Sidebar
    include Baseballbot::MarkdownHelpers

    TODAYS_GAMES = <<~'ERB'
      {{todays_games_section}}

      {{yesterday_link}}
    ERB

    def initialize(subreddit:) = super(body: TODAYS_GAMES, subreddit:)

    def todays_games_section
      @todays_games = Baseballbot::Templates::Sidebars::Components::TodaysGames.new(@subreddit).to_a

      return '' if @todays_games.none?

      <<~MARKDOWN
        # #{ath_games_header}

        #{ath_games_table}

        ^(★)Game Thread. All game times are Eastern. #{updated_with_link}
      MARKDOWN
    end

    def ath_games_header = "#{(@subreddit.now - 10_800).strftime('%A')}'s Games"

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

    @subreddit = name_to_subreddit('baseball')

    # Keep updating the same thread until 3 AM Pacific
    @date = @subreddit.now - 10_800
  end

  def update!
    submission_id = todays_submission_id

    return unless submission_id

    submission = @subreddit.load_submission id: submission_id

    @subreddit.edit id: submission_id, body: update_todays_games_in(submission)
  end

  def post!
    return if todays_submission_id

    submission = @subreddit.submit(title: post_title, text: update_todays_games_in(initial_body))

    submission.make_sticky(slot: 1)
    submission.set_suggested_sort 'new'

    redis.hset 'around_the_horn', @date.strftime('%F'), submission.id
  end

  protected

  def todays_submission_id = redis.hget('around_the_horn', @date.strftime('%F'))

  def post_title = @date.strftime('[General Discussion] Around the Horn - %-m/%-d/%y')

  def initial_body = @subreddit.subreddit.wiki_page('ath').content_md.split(/\r?\n-{3,}\r?\n/)[1].strip

  def update_todays_games_in(text)
    AroundTheHorn::ATHTemplate.new(subreddit: @subreddit).replace_in(text, delimiter: '[](/todays_games)')
  end
end

case ARGV.shift
when 'update'
  AroundTheHorn.new.update!
when 'post'
  AroundTheHorn.new.post!
end

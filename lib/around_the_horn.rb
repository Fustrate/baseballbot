# frozen_string_literal: true

require_relative 'default_bot'

class AroundTheHorn < DefaultBot
  class ATHTemplate < Baseballbot::Templates::Sidebar
    TODAYS_GAMES = <<~'ERB'
      <% games = todays_games(@subreddit.now - 10_800) %>
      <% if games.any? %>
      # <%= (@subreddit.now - 10_800).strftime('%A') %>'s Games

      Away|Score|Home|Score|Status|National
      -|:-:|-|:-:|:-:|-
      <% todays_games(@subreddit.now - 10_800).each do |game| %>
      <%= todays_games_row(game) %>

      <% end %>


      ^(★)Game Thread. All game times are Eastern. <%= updated_with_link %> <%= yesterday_link %>
      <% else %>
      <%= updated_with_link %> <%= yesterday_link %>
      <% end %>
    ERB

    def initialize(subreddit:) = super(body: '', subreddit:)

    def yesterday_link
      yesterday_id = @subreddit.bot.redis.hget('around_the_horn', (@subreddit.now - (3_600 * 27)).strftime('%F'))

      yesterday_id ? "[Yesterday's ATH](/#{yesterday_id})" : ''
    end

    def todays_games_row(game)
      [
        team_game_thread_link(game[:away]),
        game[:away][:score],
        team_game_thread_link(game[:home]),
        game[:home][:score],
        game[:status],
        game[:national]
      ].join('|')
    end

    def team_game_thread_link(team)
      text = team[:post_id] ? "#{team[:abbreviation]} ^(★)" : team[:abbreviation]

      link = team[:post_id] ? %(/#{team[:post_id]} "team-#{team[:abbreviation].downcase}") : "/r/#{team[:subreddit]}"

      "[#{text}](#{link})"
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

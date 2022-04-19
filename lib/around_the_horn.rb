# frozen_string_literal: true

# require_relative 'default_bot'

class AroundTheHorn
  TODAYS_GAMES = <<~'ERB'
    ## <%= (@subreddit.now - 10_800).strftime('%A') %>'s Games

    &nbsp;| | | | | |
    -|:-:|:-:|-|:-:|:-:
    <% todays_games(@subreddit.now - 10_800).each_slice(2) do |game1, game2| %>
    <%= game1[:away][:team] %>|<%= game1[:away][:score] %>|<%= game1[:status] %>|<%= game2[:away][:team] if game2 %>|<%= game2[:away][:score] if game2 %>|<%= game2[:status] if game2 %>

    <%= game1[:home][:team] %>|<%= game1[:home][:score] %>|<%= "^(#{game1[:national]})" if game1[:national] %>|<%= game2[:home][:team] if game2 %>|<%= game2[:home][:score] if game2 %>|<%= "^(#{game2[:national]})" if game2 && game2[:national] %>

    <% end %>


    ^(★)Game Thread. All game times are Eastern.

    <%= updated_with_link %>
  ERB

  def initialize
    @bot = DefaultBot.create(purpose: 'Around the Horn', account: 'BaseballBot')
    @subreddit = @bot.session.subreddit('baseball')

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

    submission = @subreddit.submit(post_title, text: update_todays_games_in(initial_body), sendreplies: false)

    submission.make_sticky(slot: 1)
    submission.set_suggested_sort 'new'

    @bot.redis.hset 'around_the_horn', @date.strftime('%F'), submission.id
  end

  protected

  def todays_submission_id = @bot.redis.hget('around_the_horn', @date.strftime('%F'))

  def post_title = @date.strftime('[General Discussion] Around the Horn - %-m/%-d/%y')

  def initial_body = @subreddit.wiki_page('ath').content_md.split(/\r?\n-{3,}\r?\n/)[1].strip

  def update_todays_games_in(text)
    Template::Sidebar.new(body: TODAYS_GAMES, subreddit: @subreddit).replace_in(text, delimiter: '[](/todays_games)')
  end
end

case ARGV.shift
when 'update'
  AroundTheHorn.new.update!
when 'post'
  AroundTheHorn.new.post!
end

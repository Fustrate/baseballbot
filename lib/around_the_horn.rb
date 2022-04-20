# frozen_string_literal: true

require_relative 'default_bot'

class AroundTheHorn
  TODAYS_GAMES = <<~'ERB'
    ## <%= (@subreddit.now - 10_800).strftime('%A') %>'s Games

    Away Team|@|Home Team|Status|National
    -|-|-|:-:|-
    <% todays_games(@subreddit.now - 10_800).each do |game| %>
    [<%= game[:away][:name] %><%= game[:away][:post_id] ? ' ^(★)' : '' %>](<%= game[:away][:post_id] ? "/#{game[:away][:post_id]} \"team-#{game[:away][:abbreviation].downcase}\"" : "/r/#{game[:away][:subreddit]}" %>)|@|[<%= game[:home][:name] %><%= game[:home][:post_id] ? ' ^(★)' : '' %>](<%= game[:home][:post_id] ? "/#{game[:home][:post_id]} \"team-#{game[:home][:abbreviation].downcase}\"" : "/r/#{game[:home][:subreddit]}" %>)|<%= game[:status] %>|<%= game[:national] if game[:national] %>
    <% end %>


    ^(★)Game Thread. All game times are Eastern. <%= updated_with_link %>
  ERB

  def initialize
    @bot = DefaultBot.create(purpose: 'Around the Horn', account: 'BaseballBot')
    @subreddit = @bot.name_to_subreddit('baseball')

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

    @bot.redis.hset 'around_the_horn', @date.strftime('%F'), submission.id
  end

  protected

  def todays_submission_id = @bot.redis.hget('around_the_horn', @date.strftime('%F'))

  def post_title = @date.strftime('[General Discussion] Around the Horn - %-m/%-d/%y')

  def initial_body = @subreddit.subreddit.wiki_page('ath').content_md.split(/\r?\n-{3,}\r?\n/)[1].strip

  def update_todays_games_in(text)
    Baseballbot::Template::Sidebar
      .new(body: TODAYS_GAMES, subreddit: @subreddit)
      .replace_in(text, delimiter: '[](/todays_games)')
  end
end

case ARGV.shift
when 'update'
  AroundTheHorn.new.update!
when 'post'
  AroundTheHorn.new.post!
end

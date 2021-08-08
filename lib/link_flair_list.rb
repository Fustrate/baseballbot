# frozen_string_literal: true

require_relative 'default_bot'

# Loads
class LinkFlairList
  def initialize
    raise 'Please enter a subreddit name' unless ARGV[0]

    @bot = DefaultBot.create(purpose: 'Flair Template List')

    @name = ARGV[0]
    @subreddit = @bot.session.subreddit(@name)
  end

  def run
    load_link_flairs
  end

  protected

  def load_link_flairs
    @bot.with_reddit_account(@bot.name_to_subreddit(@name).account.name) do
      @subreddit.client.get("/r/#{@name}/api/link_flair_v2").body
    end
  end
end

LinkFlairList.new.run

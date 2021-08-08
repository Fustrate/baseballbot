# frozen_string_literal: true

require 'paint'

require_relative 'default_bot'

# Loads
class LinkFlairList
  def initialize
    raise 'Please enter a subreddit name' unless ARGV[0]

    @bot = DefaultBot.create(purpose: 'Flair Template List')

    @name = ARGV[0]
  end

  def run
    load_link_flairs.each do |flair|
      puts "#{flair_display(flair)} (#{flair[:id]})"
    end
  end

  protected

  def flair_display(flair)
    if flair[:background_color] == ''
      flair[:text]
    else
      Paint[flair[:text], flair[:text_color] == 'light' ? 'fff' : '000', flair[:background_color]]
    end
  end

  def load_link_flairs
    @bot.with_reddit_account(@bot.name_to_subreddit(@name).account.name) do
      @bot.session.subreddit(@name).client.get("/r/#{@name}/api/link_flair_v2").body
    end
  end
end

LinkFlairList.new.run

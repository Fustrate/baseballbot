# frozen_string_literal: true

require_relative 'default_bot'

class ConsolidateFlairs < DefaultBot
  CHANGES = {
    'old classes' => 'new classes'
  }.freeze

  def initialize
    super(purpose: 'Merge Flairs', account: 'BaseballBot')

    @subreddit = session.subreddit('baseball')
  end

  def run = load_flairs after: ARGV[0]

  protected

  def load_flairs(after: nil)
    puts "Loading flairs#{" after #{after}" if after}"

    res = client.get('/r/baseball/api/flairlist', after:, limit: 1000).body

    res[:users].each { process_flair(it) }

    return unless res[:next]

    sleep 5

    load_flairs after: res[:next]
  end

  def process_flair(flair)
    return unless CHANGES[flair[:flair_css_class]]

    puts "\tChanging #{flair[:user]} from #{flair[:flair_css_class]} to #{CHANGES[flair[:flair_css_class]]}"

    @subreddit.set_flair(
      Redd::Models::User.new(nil, name: flair[:user]),
      flair[:flair_text],
      css_class: CHANGES[flair[:flair_css_class]]
    )
  end
end

ConsolidateFlairs.new.run

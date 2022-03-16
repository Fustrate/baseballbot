# frozen_string_literal: true

require_relative 'default_bot'

# A bot to iterate over pages of flairs
class FlairBot
  def initialize(purpose:, subreddit:)
    @bot = DefaultBot.create(purpose:)

    @name = subreddit
    @subreddit = @bot.session.subreddit(@name)

    @updates = []
  end

  def run(after: ARGV[0])
    @bot.with_reddit_account(@bot.name_to_subreddit(@name).account.name) do
      load_flair_page(after:)

      send_batch if @updates.any?
    end
  end

  protected

  def load_flair_page(after:)
    puts "Loading flairs#{after ? " after #{after}" : ''}"

    response = @subreddit.client.get("/r/#{@name}/api/flairlist", after:, limit: 1000).body

    response[:users].each do |flair|
      process_flair(flair)

      send_batch if @updates.length > 90
    end

    return unless response[:next]

    sleep 5

    load_flair_page after: response[:next]
  end

  def process_flair(_flair) = raise NotImplementedError

  def send_batch
    # Assuming there are no commas, quotes, or newlines in the data...
    flair_csv = @updates.map { _1.map(&:inspect).join(',') }.join("\n")

    puts "Committing #{@updates.count} changes..."
    puts flair_csv

    @subreddit.client.post("/r/#{@name}/api/flaircsv", flair_csv:)

    @updates = []
  end
end

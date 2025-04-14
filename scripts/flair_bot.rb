# frozen_string_literal: true

require_relative 'default_bot'

# A bot to iterate over pages of flairs
class FlairBot < DefaultBot
  BATCH_SIZE = 50

  def initialize(purpose:, subreddit:)
    super(purpose:)

    @name = subreddit

    use_account name_to_subreddit(subreddit).account.name

    @updates = []
  end

  def run(after: ARGV[0])
    load_flair_page(after:)

    # Send any updates from the last few pages
    send_batch if @updates.any?
  end

  protected

  def load_flair_page(after:)
    puts "Loading flairs#{after ? " after #{after}" : ''}"

    response = client.get("/r/#{@name}/api/flairlist", after:, limit: 1000).body

    response[:users].each do |flair|
      process_flair(flair)

      send_batch if @updates.length > self.class::BATCH_SIZE
    end

    return unless response[:next]

    sleep 5

    load_flair_page after: response[:next]
  end

  def process_flair(_flair) = raise NotImplementedError

  def send_batch
    # Assuming there are no commas, quotes, or newlines in the data...
    flair_csv = @updates.map { it.map(&:inspect).join(',') }.join("\n")

    puts "Committing #{@updates.count} changes..."
    puts flair_csv

    client.post("/r/#{@name}/api/flaircsv", flair_csv:)

    @updates = []
  end
end

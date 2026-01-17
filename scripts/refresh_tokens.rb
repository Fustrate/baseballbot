# frozen_string_literal: true

require_relative 'default_bot'

class RefreshTokens < DefaultBot
  # Someone keeps removing the BaseballBot app from the RedsModerator account
  SKIP_ACCOUNTS = %w[RedsModerator].freeze

  def initialize(bots: [])
    super(purpose: 'Refresh Tokens')

    @bot_names = bots.map(&:downcase)
  end

  def run = bots.each_value { process_account(it) }
  protected

  def process_account(bot)
    if bot.access.expired? && !skip?(bot.name)
      refresh!(bot.name)

      sleep 3
    else
      puts "Skipping #{bot.name}"
    end
  end

  def refresh!(bot_name)
    puts "Refreshing #{bot_name}"

    use_bot bot_name
  rescue Redd::Errors::APIError => e
    puts "\tError: #{e.class}"
  end

  def skip?(name) = SKIP_ACCOUNTS.include?(name) || (@bot_names.any? && !@bot_names.include?(name.downcase))
end

# frozen_string_literal: true

require_relative 'default_bot'

class RefreshTokens < DefaultBot
  # Someone keeps removing the BaseballBot app from the RedsModerator account
  SKIP_ACCOUNTS = %w[RedsModerator].freeze

  def initialize(accounts: [])
    super(purpose: 'Refresh Tokens')

    @account_names = accounts.map(&:downcase)
  end

  def run = accounts.each_value { process_account(it) }

  protected

  def process_account(account)
    if account.access.expired? && !skip?(account.name)
      refresh!(account.name)

      sleep 3
    else
      puts "Skipping #{account.name}"
    end
  end

  def refresh!(account_name)
    puts "Refreshing #{account_name}"

    use_account account_name
  rescue Redd::Errors::APIError => e
    puts "\tError: #{e.class}"
  end

  def skip?(name) = SKIP_ACCOUNTS.include?(name) || (@account_names.any? && !@account_names.include?(name.downcase))
end

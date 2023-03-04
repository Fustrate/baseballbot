# frozen_string_literal: true

require_relative 'default_bot'

class RefreshTokens < DefaultBot
  def initialize(accounts: [])
    super(purpose: 'Refresh Tokens')

    @account_names = accounts.map(&:downcase)
  end

  def run
    accounts.each_value do |account|
      process_account(account)

      sleep 5
    end
  end

  def process_account(account)
    return if skip_account?(account.name)

    if account.access.expired?
      refresh!(account.name)
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

  def skip_account?(name) = @account_names.any? && !@account_names.include?(name.downcase)
end

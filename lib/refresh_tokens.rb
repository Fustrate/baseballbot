# frozen_string_literal: true

require_relative 'default_bot'

@bot = DefaultBot.create(purpose: 'Refresh Tokens')

@names = ARGV[0]&.downcase&.split(',') || []

@bot.accounts.each_value do |account|
  next if @names.any? && !@names.include?(account.name.downcase)

  unless account.access.expired?
    puts "Skipping #{account.name}"

    next
  end

  begin
    puts "Refreshing #{account.name}"

    @bot.use_account account.name
  rescue Redd::Errors::APIError => e
    puts "\tError: #{e.class}"
  end

  sleep 5
end

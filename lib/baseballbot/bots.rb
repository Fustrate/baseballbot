# frozen_string_literal: true

class Baseballbot
  module Bots
    attr_reader :bots, :current_bot

    def with_reddit_bot(bot_name, &)
      tries ||= 0

      use_bot(bot_name)

      Honeybadger.context(bot_name:, &)
    rescue Redd::Errors::InvalidAccess
      refresh_access!

      # We *should* only get an invalid access error once, but let's be safe.
      raise unless (tries += 1) < 2

      retry
    end

    def use_bot(bot_name)
      unless @current_bot&.name == bot_name
        @current_bot = bots.values.find { it.name == bot_name }

        client.access = @current_bot.access
      end

      refresh_access! if @current_bot.access.expired?
    end

    def refresh_access!
      client.refresh

      return if client.access.to_h[:error]

      new_expiration = Time.now + client.access.expires_in

      update_token_expiration!(new_expiration)

      client
    end

    protected

    def update_token_expiration!(new_expiration)
      Baseballbot::Models::Bot
        .where(refresh_token: client.access.refresh_token)
        .update(access_token: client.access.access_token, expires_at: new_expiration.strftime('%F %T'))
    end

    def load_bots = Baseballbot::Models::Bot.all.to_h { [it.id, process_bot_row(it)] }

    def process_bot_row(row) = Bot.new(bot: self, name: row.name, access: account_access(row))

    def account_access(row)
      Redd::Models::Access.new(
        access_token: row.access_token,
        refresh_token: row.refresh_token,
        scope: row.scope.join(' '),
        # Remove 60 seconds so we don't run into invalid credentials
        expires_at: row.expires_at - 60,
        expires_in: row.expires_at - Time.now
      )
    end
  end
end

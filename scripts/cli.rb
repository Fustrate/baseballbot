# frozen_string_literal: true

# Copyright (c) Valencia Management Group
# All rights reserved.

require 'thor'

class CLI < Thor
  package_name 'BaseballBot'

  desc 'check_messages', 'Check for messages from other bots'
  def check_messages
    require_relative 'check_messages'

    CheckMessages.new.run
  end

  desc 'sync_moderators'
  method_option :subreddits, type: :string, aliases: '-s'
  def sync_moderators
    require_relative 'sync_moderators'

    SyncModerators.new(subreddits: options.subreddits&.split(/[,+]/ || [])).run
  end
end

CLI.start

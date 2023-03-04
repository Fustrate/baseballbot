# frozen_string_literal: true

# Copyright (c) Valencia Management Group
# All rights reserved.

require 'thor'

require_relative 'cli/game_threads'
require_relative 'cli/sidebars'

class CLI < Thor
  desc 'game_threads', 'Game thread commands'
  subcommand 'game_threads', GameThreads

  desc 'sidebars', 'Sidebar commands'
  subcommand 'sidebars', Sidebars

  desc 'around_the_horn', 'Post the daily /r/baseball ATH thread'
  def around_the_horn
    require_relative 'around_the_horn'

    AroundTheHorn.new.run
  end

  desc 'chaos', 'Burn the wagons!'
  method_option :teams, type: :string, required: true
  method_option :after, type: :string
  def chaos
    require_relative 'chaos'

    Chaos.new(teams: options.teams.split(/[,+]/)).run(after: options.after)
  end

  desc 'check_messages', 'Check for messages from other bots'
  def check_messages
    require_relative 'check_messages'

    CheckMessages.new.run
  end

  desc 'sync_moderators', 'Sync moderator names from reddit'
  method_option :subreddits, type: :string, aliases: '-s'
  def sync_moderators
    require_relative 'sync_moderators'

    SyncModerators.new(subreddits: parse_subreddits(options.subreddits)).run
  end

  desc 'no_hitters', 'Post game threads for no-hitters in progress'
  def no_hitters
    require_relative 'no_hitters'

    NoHitters.new.post_no_hitters!
  end

  desc 'slack', 'Send new mod queue items to Slack'
  def slack
    require_relative 'mod_queue_slack'

    ModQueueSlack.new.run!
  end

  desc 'tokens', 'Refresh reddit account tokens'
  method_option :accounts, type: :string
  def tokens
    require_relative 'refresh_tokens'

    RefreshTokens.new(accounts: parse_subreddits(options.accounts)).run
  end
end

CLI.start

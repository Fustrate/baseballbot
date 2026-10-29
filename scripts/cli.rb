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
  method_option :bots, type: :string
  def tokens
    require_relative 'refresh_tokens'

    RefreshTokens.new(bots: parse_array(options.bots)).run
  end

  protected

  def parse_array(input) = input&.split(/[,+]/) || []
end

CLI.start

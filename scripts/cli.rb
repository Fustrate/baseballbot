# frozen_string_literal: true

# Copyright (c) Valencia Management Group
# All rights reserved.

require 'thor'

def parse_subreddits(input) = input&.split(/[,+]/) || []

class Subcommand < Thor
  def self.banner(command, _namespace = nil, _subcommand = nil)
    "#{basename} #{subcommand_prefix} #{command.usage}"
  end

  def self.subcommand_prefix
    name.gsub(/.*::/, '').gsub(/^[A-Z]/) { _1[0].downcase }.gsub(/[A-Z]/) { "-#{_1[0].downcase}" }
  end
end

class CLI < Thor
  package_name 'BaseballBot'

  class Sidebars < Subcommand
    desc 'update', 'Update one or more subreddit sidebars'
    method_option :subreddits, type: :string, aliases: '-s'
    def update
      require_relative 'default_bot'

      DefaultBot.new(purpose: 'Update Sidebars').update_sidebars!(names: parse_subreddits(options.subreddits))
    end

    desc 'show', 'Display the current sidebar markdown for a subreddit'
    method_option :subreddit, type: :string, required: true, aliases: '-s'
    def show
      require_relative 'default_bot'

      puts DefaultBot.new(purpose: 'Display Sidebar').show_sidebar(options.subreddit)
    end
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

  desc 'sidebars', 'Update sidebars'
  subcommand 'sidebars', Sidebars

  desc 'sync_moderators', 'Sync moderator names from reddit'
  method_option :subreddits, type: :string, aliases: '-s'
  def sync_moderators
    require_relative 'sync_moderators'

    SyncModerators.new(subreddits: parse_subreddits(options.subreddits)).run
  end
end

CLI.start

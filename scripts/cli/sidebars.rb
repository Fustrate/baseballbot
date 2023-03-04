# frozen_string_literal: true

# Copyright (c) Valencia Management Group
# All rights reserved.

require_relative 'subcommand'

class Sidebars < Subcommand
  desc 'update', 'Update one or more subreddit sidebars'
  method_option :subreddits, type: :string, aliases: '-s'
  def update
    require_relative '../default_bot'

    DefaultBot.new(purpose: 'Update Sidebars').update_sidebars!(names: parse_subreddits(options.subreddits))
  end

  desc 'show', 'Display the current sidebar markdown for a subreddit'
  method_option :subreddit, type: :string, required: true, aliases: '-s'
  def show
    require_relative '../default_bot'

    puts DefaultBot.new(purpose: 'Display Sidebar').show_sidebar(options.subreddit)
  end
end

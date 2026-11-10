# frozen_string_literal: true

# Copyright (c) Valencia Management Group
# All rights reserved.

require_relative 'subcommand'

class Sidebars < Subcommand
  desc 'update', 'Update one or more subreddit sidebars'
  method_option :subreddits, type: :string, aliases: '-s'
  def update
    require_relative '../default_bot'

    DefaultBot.new(purpose: 'Update Sidebars').update_sidebars!(names: parse_array(options.subreddits))
  end
end

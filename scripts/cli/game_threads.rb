# frozen_string_literal: true

# Copyright (c) Valencia Management Group
# All rights reserved.

require_relative 'subcommand'

class GameThreads < Subcommand
  desc 'off_day', 'Post daily off-day threads'
  method_option :subreddits, type: :string, aliases: '-s'
  def off_day
    require_relative '../default_bot'

    DefaultBot.new(purpose: 'Post ODTs').post_off_day_threads! names: parse_array(options.subreddits)
  end
end

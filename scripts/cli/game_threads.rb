# frozen_string_literal: true

# Copyright (c) Valencia Management Group
# All rights reserved.

require_relative 'subcommand'

class GameThreads < Subcommand
  desc 'load', 'Load game threads for one or more subreddits'
  method_option :month, type: :string, aliases: '-m'
  method_option :subreddits, type: :string, aliases: '-s'
  def load
    require_relative '../load_game_threads'

    results = GameThreadLoader.new(
      date: month_to_date(options.month),
      subreddits: parse_array(options.subreddits)
    ).run

    puts "Added #{results[:created]}, Updated #{results[:updated]}"
  end

  desc 'load_postseason', ''
  def load_postseason
    require_relative '../load_postseason_game_threads'

    PostseasonGameLoader.new.run
  end

  desc 'load_sunday', ''
  def load_sunday
    require_relative '../load_sunday_game_threads'

    SundayGameThreadLoader.new.run
  end

  desc 'off_day', 'Post daily off-day threads'
  method_option :subreddits, type: :string, aliases: '-s'
  def off_day
    require_relative '../default_bot'

    DefaultBot.new(purpose: 'Post ODTs').post_off_day_threads! names: parse_array(options.subreddits)
  end

  desc 'post', 'Post game threads'
  method_option :subreddits, type: :string, aliases: '-s'
  def post
    require_relative '../default_bot'

    DefaultBot.new(purpose: 'Post GDTs').post_game_threads! names: parse_array(options.subreddits)
  end

  desc 'pregame', 'Post daily pregame threads'
  method_option :subreddits, type: :string, aliases: '-s'
  def pregame
    require_relative '../default_bot'

    DefaultBot.new(purpose: 'Post PreGTs').post_pregame_threads! names: parse_array(options.subreddits)
  end

  desc 'update', 'Update active game threads'
  method_option :subreddits, type: :string, aliases: '-s'
  method_option :posted, type: :boolean
  def update
    require_relative '../default_bot'

    # TODO: Implement options.posted
    DefaultBot.new(purpose: 'Update GDT').update_game_threads! names: parse_array(options.subreddits)
  end

  protected

  def month_to_date(month) = Date.new(Date.today.year, month ? month.to_i : Date.today.month, 1)
end

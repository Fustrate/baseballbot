# frozen_string_literal: true

require_relative 'default_bot'

case ARGV.shift
when 'post'
  DefaultBot.new(purpose: 'Post GDTs').post_game_threads! names: ARGV
when 'update'
  DefaultBot.new(purpose: 'Update GDT').update_game_threads! names: ARGV
when 'pregame'
  DefaultBot.new(purpose: 'Post PreGTs').post_pregame_threads! names: ARGV
when 'off_day'
  DefaultBot.new(purpose: 'Post ODTs').post_off_day_threads! names: ARGV
end

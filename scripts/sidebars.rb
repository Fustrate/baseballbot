# frozen_string_literal: true

require_relative 'default_bot'

case ARGV.shift
when 'update'
  DefaultBot.new(purpose: 'Update Sidebars').update_sidebars! names: ARGV
when 'show'
  puts DefaultBot.new(purpose: 'Display Sidebar').show_sidebar ARGV[0]
end

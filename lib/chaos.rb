# frozen_string_literal: true

require_relative 'flair_bot'

class Chaos < FlairBot
  def initialize
    raise 'Pass 1-2 arguments: chaos.rb SFG,CHC [t2_123456]' unless ARGV[0] && ARGV.count < 3

    @remove_flairs = ARGV[0].split(',').map { |team| "#{team}-wagon" }

    super(purpose: 'Chaos Flairs', subreddit: 'baseball')

    @removed = Hash.new { |h, k| h[k] = 0 }
  end

  def run(after: ARGV[1])
    puts "Removing #{@remove_flairs.join(', ')}"

    super

    counts = @removed.map { |flair, count| [count, flair].join(' ') }

    puts "Removed: #{counts.join(', ')}"
  end

  protected

  def process_flair(flair)
    return unless @remove_flairs.include?(flair[:flair_css_class])

    puts "\tChanging #{flair[:user]} from #{flair[:flair_css_class]} to CHAOS"

    @removed[flair[:flair_css_class]] += 1

    @updates << [flair[:user], 'Team Chaos', 'CHAOS-wagon']
  end
end

Chaos.new.run

# frozen_string_literal: true

require_relative 'flair_bot'

class Chaos < FlairBot
  def initialize(teams:)
    @remove_flairs = teams.map { "#{it}-wagon" }

    super(purpose: 'Chaos Flairs', subreddit: 'baseball')

    @removed = Hash.new { |h, k| h[k] = 0 }
  end

  def run(after:)
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

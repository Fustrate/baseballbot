# frozen_string_literal: true

require_relative 'flair_bot'
require 'csv'

class FlairList < FlairBot
  def initialize
    raise 'Please enter a subreddit name' unless ARGV[0]

    super(purpose: 'Flair List', subreddit: ARGV[0])

    @users = []
  end

  def run(after: nil)
    super

    CSV.open(File.expand_path("~/flair_#{@name}.csv"), 'w', headers: %w[Name CSS Text]) do |csv|
      @users.each { |user| csv << user }
    end
  end

  protected

  def process_flair(flair)
    @users << [flair[:user], flair[:flair_css_class], flair[:flair_text]]
  end
end

# We can't restart this, so start from the beginning
FlairList.new.run

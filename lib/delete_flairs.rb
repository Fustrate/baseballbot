# frozen_string_literal: true

require_relative 'flair_bot'

class DeleteFlairs < FlairBot
  def initialize
    super(purpose: 'Delete Flairs', subreddit: ARGV[0])

    @classes = ARGV[1].split(',')
  end

  def run(after: ARGV[2]) = (super if @classes.any?)

  protected

  def process_flair(flair)
    return unless @classes.include? flair[:flair_css_class]

    puts "\tDeleting #{flair[:user]}'s flair: '#{flair[:flair_css_class]}', '#{flair[:flair_text]}'"

    @updates << [flair[:user], '', '']
  end
end

DeleteFlairs.new.run

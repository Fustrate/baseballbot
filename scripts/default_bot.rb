# frozen_string_literal: true

require_relative '../lib/baseballbot'

require 'fileutils'

# The bare basics of most of these scripts
class DefaultBot < Baseballbot
  def initialize(purpose: nil, bot: nil)
    super(
      user_agent: ['Baseballbot by /u/Fustrate', purpose].compact.join(' - '),
      logger: Logger.new(log_location)
    )

    use_bot(bot) if bot
  end

  protected

  def log_location
    return $stdout if ARGV.any? { it.match?(/\Alog=(?:1|stdout)\z/i) }

    File.expand_path('../log/baseballbot.log', __dir__).tap { FileUtils.touch(it) }
  end
end

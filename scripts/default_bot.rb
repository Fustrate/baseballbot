# frozen_string_literal: true

require_relative '../lib/baseballbot'

require 'fileutils'

# The bare basics of most of these scripts
class DefaultBot < Baseballbot
  def initialize(purpose: nil, account: nil)
    super(
      user_agent: ['Baseballbot by /u/Fustrate', purpose].compact.join(' - '),
      logger: Logger.new(log_location)
    )

    use_account(account) if account
  end

  protected

  def log_location
    return $stdout if ARGV.any? { _1.match?(/\Alog=(?:1|stdout)\z/i) }

    File.expand_path('../log/baseballbot.log', __dir__).tap { FileUtils.touch(_1) }
  end
end

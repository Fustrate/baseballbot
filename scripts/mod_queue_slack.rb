# frozen_string_literal: true

require_relative 'default_bot'

require 'uri'
require 'net/http'
require 'net/https'
require 'json'

SLACK_HOOK_ID = ENV.fetch('DODGERS_SLACK_HOOK_ID')

class ModQueueSlack < DefaultBot
  def initialize
    super(purpose: 'Mod Queue', account: 'DodgerBot')

    @subreddit = session.subreddit('Dodgers')

    @uri = URI.parse("https://hooks.slack.com/services/#{SLACK_HOOK_ID}")

    @https = Net::HTTP.new(@uri.host, @uri.port)
    @https.use_ssl = true
  end

  def run!(retry_on_failure: true)
    @subreddit.modqueue(limit: 10).each { process_item(it) }
  rescue Redd::Errors::APIError
    return unless retry_on_failure

    puts 'Service unavailable: waiting 30 seconds to retry.'

    sleep 30

    run!(retry_on_failure: false)
  rescue => e
    Honeybadger.notify(e)
  end

  protected

  def process_item(item)
    # Only send submissions to slack
    return unless item.is_a?(Redd::Models::Submission)

    return if redis.hget('dodgers_mod_queue', item.name)

    send_to_slack slack_message(item)

    redis.hset 'dodgers_mod_queue', item.name, 1

    # Don't flood the slack channel
    sleep(5)
  end

  def slack_message(item)
    {
      text: "*#{item.author.name}* was reported for:",
      attachments: [
        body_attachment(item),
        mod_queue_reason(item)
      ]
    }
  end

  def body_attachment(item)
    {
      text: item.selftext[0..255],
      title: item.title,
      title_link: "https://www.reddit.com#{item.permalink}"
    }
  end

  def mod_queue_reason(item)
    reports = item.mod_reports + item.user_reports
    reasons = reports.map { |reason, number| "#{reason} (#{number})" }

    {
      text: reports.any? ? "Reports: #{reasons.join(', ')}" : 'Spam?',
      callback_id: item.name,
      fallback: 'Uh oh! Something went wrong.'
    }
  end

  def send_to_slack(message)
    request = Net::HTTP::Post.new(@uri.path, 'Content-Type' => 'application/json')
    request.body = message.to_json

    response = @https.request(request)

    raise 'Uh oh!' unless response.code.to_i == 200
  end
end

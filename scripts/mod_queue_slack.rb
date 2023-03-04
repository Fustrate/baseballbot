# frozen_string_literal: true

require_relative 'default_bot'

require 'uri'
require 'net/http'
require 'net/https'
require 'json'

SLACK_HOOK_ID = ENV.fetch('DODGERS_SLACK_HOOK_ID')

class ModQueueSlack < DefaultBot
  ACTIONS = [
    {
      name: 'queue_action',
      text: 'Approve',
      style: 'primary',
      type: 'button',
      value: 'approve'
    },
    {
      name: 'queue_action',
      text: 'Remove',
      style: 'danger',
      type: 'button',
      value: 'remove',
      confirm: {
        title: 'Confirm Removal',
        text: 'Are you sure you want to remove this item?',
        ok_text: 'Yes',
        dismiss_text: 'No'
      }
    },
    {
      name: 'queue_action',
      text: 'Mark as Spam',
      style: 'danger',
      type: 'button',
      value: 'spam',
      confirm: {
        title: 'Confirm Spam',
        text: 'Are you sure you want to mark this item as spam?',
        ok_text: 'Yes',
        dismiss_text: 'No'
      }
    }
  ].freeze

  def initialize
    super(purpose: 'Mod Queue', account: 'DodgerBot')

    @subreddit = session.subreddit('Dodgers')

    @uri = URI.parse("https://hooks.slack.com/services/#{SLACK_HOOK_ID}")

    @https = Net::HTTP.new(@uri.host, @uri.port)
    @https.use_ssl = true
  end

  def run!(retry_on_failure: true)
    @subreddit.modqueue(limit: 10).each { process_item(_1) }
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
      text: item_body(item),
      title: item_title(item),
      title_link: "https://www.reddit.com#{item.permalink}"
    }
  end

  def mod_queue_reason(item)
    reports = item.mod_reports + item.user_reports
    reasons = reports.map { |reason, number| "#{reason} (#{number})" }

    {
      text: reports.any? ? "Reports: #{reasons.join(', ')}" : 'Spam?',
      actions: ACTIONS,
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

  def item_body(item) = item.is_a?(Redd::Models::Submission) ? item.selftext[0..255] : item.body

  def item_title(item) = item.is_a?(Redd::Models::Submission) ? item.title : item.link_title
end

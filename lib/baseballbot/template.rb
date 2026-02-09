# frozen_string_literal: true

require 'mustache'

class Time
  def short_day_of_week = strftime('%a')
end

class Baseballbot
  class Template < Mustache
    include MarkdownHelpers

    include Templates::Components

    DELIMITER = '[](/baseballbot)'

    attr_reader :subreddit

    def initialize(body:, subreddit:, blocks: nil)
      super()

      self.template = body || ''
      @blocks = blocks

      @subreddit = subreddit
    end

    def instance_variables_to_inspect = %i[@subreddit]

    def evaluated_body
      # Allow both Mustache and ERB until all templates are converted, then rip out ERB.
      ERB.new(render, trim_mode: '<>').result(binding)
    rescue SyntaxError => e
      Honeybadger.notify(e, context: { template: })
      raise StandardError, 'ERB syntax error'
    end

    # Don't escape values in templates - this is all markdown in the end.
    def escape(value) = value

    def replace_in(text, delimiter: DELIMITER)
      text = CGI.unescapeHTML(text.selftext) if text.is_a?(Redd::Models::Submission)

      text.sub replace_regexp(delimiter:), "#{delimiter}\n#{evaluated_body}\n#{delimiter}"
    end

    def timestamp(action = nil)
      time = @subreddit.now.strftime '%-I:%M %p'

      "*#{action ? "#{action} at #{time}." : time}*"
    end

    def year = @subreddit.today.year

    def month_name = @subreddit.today.strftime('%B')

    protected

    def replace_regexp(delimiter: DELIMITER)
      escaped_delimiter = Regexp.escape delimiter

      Regexp.new "#{escaped_delimiter}(.*)#{escaped_delimiter}", Regexp::MULTILINE
    end
  end
end

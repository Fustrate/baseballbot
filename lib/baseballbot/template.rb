# frozen_string_literal: true

require 'mustache'

class Baseballbot
  class Template < Mustache
    include MarkdownHelpers

    DELIMITER = '[](/baseballbot)'

    attr_reader :subreddit

    def initialize(body:, subreddit:)
      super()

      self.template = body

      @subreddit = subreddit
    end

    def evaluated_body
      # Allow both Mustache and ERB until all templates are converted, then rip out ERB.
      ERB.new(render, trim_mode: '<>').result(binding)
    rescue SyntaxError => e
      Honeybadger.notify(e, context: { template: })
      raise StandardError, 'ERB syntax error'
    end

    def replace_in(text, delimiter: DELIMITER)
      text = CGI.unescapeHTML(text.selftext) if text.is_a?(Redd::Models::Submission)

      text.sub replace_regexp(delimiter:), "#{delimiter}\n#{evaluated_body}\n#{delimiter}"
    end

    def timestamp(action = nil)
      time = @subreddit.now.strftime '%-I:%M %p'

      "*#{action ? "#{action} at #{time}." : time}*"
    end

    protected

    def replace_regexp(delimiter: DELIMITER)
      escaped_delimiter = Regexp.escape delimiter

      Regexp.new "#{escaped_delimiter}(.*)#{escaped_delimiter}", Regexp::MULTILINE
    end
  end
end

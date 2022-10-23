# frozen_string_literal: true

Dir.glob(File.join(File.dirname(__FILE__), 'shared', '*.rb')).each { require_relative _1 }

class Baseballbot
  module Template
    class Base
      include MarkdownHelpers
      using TemplateRefinements

      include Template::Shared::Calendar
      include Template::Shared::Standings

      DELIMITER = '[](/baseballbot)'

      def initialize(body:, subreddit:)
        @subreddit = subreddit
        @body = body
      end

      def evaluated_body
        ERB.new(@body, trim_mode: '<>').result(binding)
      rescue SyntaxError => e
        Honeybadger.notify(e, context: { template: @body })
        raise StandardError, 'ERB syntax error'
      end

      # Get the default subreddit for this team
      def subreddit(code)
        name = @subreddit.options.dig('subreddits', code.upcase) || @subreddit.bot.default_subreddit(code)

        @subreddit.options.dig('subreddits', 'downcase') ? name.downcase : name
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
end

# frozen_string_literal: true

class Baseballbot
  module Template
    class Base
      # This is kept here because of inheritance
      Dir.glob(File.join(File.dirname(__FILE__), 'shared', '*.rb')).each { require_relative _1 }

      include MarkdownHelpers
      using TemplateRefinements

      include Template::Shared::Calendar
      include Template::Shared::Standings

      DELIMITER = '[](/baseballbot)'

      def initialize(body:, subreddit:)
        @subreddit = subreddit
        @template_body = body

        @erb = ERB.new body, trim_mode: '<>'
        @bot = subreddit.bot
      end

      def evaluated_body
        @erb.result(binding)
      rescue SyntaxError => e
        Honeybadger.notify(e, context: { template: @template_body })
        raise StandardError, 'ERB syntax error'
      end

      # Get the default subreddit for this team
      def subreddit(code)
        name = @subreddit.options.dig('subreddits', code.upcase) || @bot.default_subreddit(code)

        @subreddit.options.dig('subreddits', 'downcase') ? name.downcase : name
      end

      def replace_regexp(delimiter: DELIMITER)
        escaped_delimiter = Regexp.escape delimiter

        Regexp.new "#{escaped_delimiter}(.*)#{escaped_delimiter}", Regexp::MULTILINE
      end

      def replace_in(text, delimiter: DELIMITER)
        text = CGI.unescapeHTML(text.selftext) if text.is_a?(Redd::Models::Submission)

        text.sub replace_regexp(delimiter:), "#{delimiter}\n#{evaluated_body}\n#{delimiter}"
      end

      def timestamp(action = nil)
        return @subreddit.now.strftime '%-I:%M %p' unless action

        italic "#{action} at #{@subreddit.now.strftime '%-I:%M %p'}."
      end
    end
  end
end

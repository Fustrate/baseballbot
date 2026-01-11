# frozen_string_literal: true

class Baseballbot
  module Templates
    class Block
      include MarkdownHelpers

      attr_reader :subreddit, :template, :attributes

      def initialize(subreddit, template:, **attributes)
        @subreddit = subreddit
        @template = template
        @attributes = attributes
      end

      def interpolate(text)
        text.gsub(/\{\{(year|month_name)\}\}/) do
          template.send(Regexp.last_match(1))
        end
      end

      def render = raise NotImplementedError
    end
  end
end

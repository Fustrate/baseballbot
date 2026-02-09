# frozen_string_literal: true

class Baseballbot
  module Templates
    class Sidebar < Template
      include Sidebars::Components

      def evaluated_body
        return super unless @blocks && !@blocks.empty?

        @blocks
          .map { block_for(it) }
          .append(updated_with_link)
          .join("\n\n")
      end

      def block_for(block)
        case block['type']
        when 'division_standings'
          Blocks::DivisionStandings.new(subreddit, template: self, **block).render
        when 'calendar'
          Blocks::Calendar.new(subreddit, template: self, **block).render
        else
          block['content']
        end
      end

      def updated_with_link = "[Updated](https://baseballbot.io) #{@subreddit.now.strftime('%-m/%-d at %-I:%M %p %Z')}"
    end
  end
end

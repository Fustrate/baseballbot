# frozen_string_literal: true

class Baseballbot
  module Templates
    class Sidebar < Template
      include Sidebars::Components

      def evaluated_body
        return super unless @blocks && !@blocks.empty?

        @blocks
          .map { block_for(it) }
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
    end
  end
end

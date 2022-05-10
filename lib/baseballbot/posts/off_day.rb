# frozen_string_literal: true

class Baseballbot
  module Posts
    class OffDay < Base
      # Off day threads don't come from a table row
      def initialize(subreddit:) = super({ 'title' => subreddit.options.dig('off_day', 'title') }, subreddit:)

      def create!
        @template = off_day_template

        @submission = @subreddit.submit(
          title: @template.formatted_title,
          text: @template.evaluated_body,
          flair_id: @subreddit.options.dig('off_day', 'flair_id')
        )

        update_sticky(@subreddit.options.dig('off_day', 'sticky') != false)

        info "[OFF] Submitted off day thread #{@submission.id} in /r/#{@name}"

        @submission
      end

      protected

      def off_day_template
        Template::General.new(
          body: @subreddit.template_for('off_day'),
          subreddit: @subreddit,
          title: @subreddit.options.dig('off_day', 'title')
        )
      end
    end
  end
end

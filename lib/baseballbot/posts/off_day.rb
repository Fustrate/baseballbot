# frozen_string_literal: true

class Baseballbot
  module Posts
    class OffDay < Base
      def create!
        @template = off_day_template

        @submission = @subreddit.submit(
          title: @template.formatted_title,
          text: @template.evaluated_body,
          flair_id: @subreddit.options.dig('off_day', 'flair_id')
        )

        update_sticky(@subreddit.options.dig('off_day', 'sticky') != false)

        info "[OFF] Submitted off day thread #{@submission.id} in /r/#{@name}"

        post_sticky_comment

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

      def post_sticky_comment = post_comment(subreddit.options.dig('off_day', 'sticky_comment'))
    end
  end
end

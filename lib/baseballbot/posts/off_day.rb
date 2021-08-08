# frozen_string_literal: true

class Baseballbot
  module Posts
    class OffDay < Base
      def create!
        @template = off_day_template

        @submission = @subreddit.submit(
          title: @template.formatted_title,
          text: @template.evaluated_body,
          flair_id: flair['flair_template_id']
        )

        update_sticky(@subreddit.options.dig('off_day', 'sticky') != false)
        update_flair flair unless flair['flair_template_id']

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

      def flair
        @flair ||= @subreddit.options.dig('off_day', 'flair') || {}
      end
    end
  end
end

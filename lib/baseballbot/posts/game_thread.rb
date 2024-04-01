# frozen_string_literal: true

class Baseballbot
  module Posts
    class GameThread < Base
      attr_reader :game_pk, :title

      def initialize(row, subreddit:)
        super(subreddit:)

        @row = row

        @id = row['id']
        @game_pk = row['game_pk']
        @post_id = row['post_id']
        @type = row['type'] || 'game_thread'
        @title = row['title']
      end

      def create!
        @template = post_template(@type)

        return change_status('Postponed') if @template.postponed?

        create_game_thread_post!

        info "[NEW] #{submission.id} in /r/#{subreddit.name} for #{game_pk}"

        submission
      end

      def update!
        @template = post_template("#{@type}_update")
        @submission = subreddit.load_submission(id: @post_id)

        return reddit_submission_removed! unless submission.banned_by.nil?

        update_game_thread_post!

        info "[UPD] #{submission.id} in /r/#{subreddit.name} for #{game_pk}"
      end

      protected

      def create_game_thread_post!
        @submission = subreddit.submit(
          title: @template.formatted_title,
          text: @template.evaluated_body,
          flair_id: game_thread_flair('default')
        )

        # Mark as posted right away so that it won't post again
        change_status 'Posted'

        update_sticky subreddit.sticky_game_threads?
        update_suggested_sort 'new'
        post_sticky_comment
      end

      def update_game_thread_post!
        subreddit.edit id: @post_id, body: @template.replace_in(submission)

        return postpone_game_thread! if @template.postponed?

        @template.final? ? end_game_thread! : change_status('Posted')
      end

      # @param status [String] status of the game thread
      def change_status(status)
        attrs = updated_attributes(status)

        fields = attrs.keys.map.with_index { |col, i| "#{col} = $#{i + 2}" }

        bot.db.exec_params "UPDATE game_threads SET #{fields.join(', ')} WHERE id = $1", [@id] + attrs.values
      end

      def updated_attributes(status)
        return { status:, updated_at: Time.now } unless status == 'Posted'

        {
          status:,
          updated_at: Time.now,
          post_id: submission.id,
          title: submission.title
        }
      end

      # Mark the game thread as complete, and make any last updates
      def end_game_thread!
        change_status 'Over'

        update_sticky(false) if subreddit.sticky_game_threads?

        info "[END] #{submission.id} in /r/#{subreddit.name} for #{game_pk}"

        post_postgame!

        set_postgame_flair!
      end

      def reddit_submission_removed!
        change_status 'Removed'

        info "[REM] #{submission.id} in /r/#{subreddit.name} for #{game_pk}"
      end

      # If this subreddit has flair settings, apply them at the end of the game
      def set_postgame_flair!
        if @template.won?
          update_flair game_thread_flair('won')
        elsif @template.lost?
          update_flair game_thread_flair('lost')
        end
      end

      def postpone_game_thread!
        change_status 'Postponed'

        info "[PPD] #{submission.id} in /r/#{subreddit.name} for #{game_pk}"

        post_postgame!
      end

      # Create a postgame thread if the subreddit is set to have them
      #
      # @return [Redd::Models::Submission] the postgame thread
      def post_postgame!
        return unless subreddit.options.dig('postgame', 'enabled') && @type == 'game_thread' && !postgame_posted?

        Baseballbot::Posts::Postgame.new(@row, subreddit:).create!
      end

      def game_thread_flair(type) = subreddit.options.dig('game_threads', 'flair_id', type)

      def post_template(type) = Templates::GameThread.new(subreddit:, game_pk:, post_id: @post_id, type:, title:)

      # When there are lots of threads running at the same time, the updates may take so long that it's still running
      # when the next update triggers. Make sure there hasn't been a postgame thread ID set since we loaded this round.
      def postgame_posted?
        result = bot.db.exec_params('SELECT post_game_post_id FROM game_threads WHERE id = $1', [@id])[0]

        !result['post_game_post_id'].nil?
      end

      def post_sticky_comment = post_comment(text: subreddit.options.dig('game_threads', 'sticky_comment'))
    end
  end
end

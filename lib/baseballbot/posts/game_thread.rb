# frozen_string_literal: true

class Baseballbot
  module Posts
    class GameThread < Base
      def initialize(row, subreddit:)
        super(row, subreddit: subreddit)

        @row = row

        @id = row['id']
        @game_pk = row['game_pk']
        @post_id = row['post_id']
        @type = row['type'] || 'game_thread'
        @title = row['title']
      end

      def create!
        @template = template_for(@type)

        return change_status('Postponed') if @template.postponed?

        create_game_thread_post!

        info "[NEW] #{@submission.id} in /r/#{@subreddit.name} for #{@game_pk}"

        save_to_redis!

        @submission
      end

      def update!
        @template = template_for("#{@type}_update")
        @submission = @subreddit.load_submission(id: @post_id)

        return reddit_submission_removed! unless @submission.banned_by.nil?

        update_game_thread_post!

        info "[UPD] #{@submission.id} in /r/#{@subreddit.name} for #{@game_pk}"
      end

      protected

      def create_game_thread_post!
        @submission = @subreddit.submit(
          title: @template.formatted_title,
          text: @template.evaluated_body
        )

        # Mark as posted right away so that it won't post again
        change_status 'Posted'

        update_sticky @subreddit.sticky_game_threads?
        update_suggested_sort 'new'
        # update_flair game_thread_flair('default')
      end

      def update_game_thread_post!
        @subreddit.edit id: @post_id, body: @template.replace_in(@submission)

        return postpone_game_thread! if @template.postponed?

        @template.final? ? end_game_thread! : change_status('Posted')
      end

      def save_to_redis!
        bot.redis.hset(@template.gid, @subreddit.name.downcase, @submission.id)
      end

      # @param status [String] status of the game thread
      def change_status(status)
        attrs = { status: status, updated_at: Time.now }

        if status == 'Posted'
          attrs[:post_id] = @submission.id
          attrs[:title] = @submission.title
        end

        fields = attrs.keys.map.with_index { |col, i| "#{col} = $#{i + 2}" }

        bot.db.exec_params "UPDATE game_threads SET #{fields.join(', ')} WHERE id = $1", [@id] + attrs.values
      end

      # Mark the game thread as complete, and make any last updates
      def end_game_thread!
        change_status 'Over'

        update_sticky(false) if @subreddit.sticky_game_threads?

        info "[END] #{@submission.id} in /r/#{@subreddit.name} for #{@game_pk}"

        post_postgame!

        set_postgame_flair!
      end

      def reddit_submission_removed!
        change_status 'Removed'

        info "[REM] #{@submission.id} in /r/#{@subreddit.name} for #{@game_pk}"
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

        info "[PPD] #{@submission.id} in /r/#{@subreddit.name} for #{@game_pk}"

        post_postgame!
      end

      # Create a postgame thread if the subreddit is set to have them
      #
      # @param game_pk [String] the MLB game ID
      #
      # @return [Redd::Models::Submission] the postgame thread
      def post_postgame!
        return unless @subreddit.options.dig('postgame', 'enabled')

        # Only game threads get post game threads, right?
        return unless @type == 'game_thread'

        Baseballbot::Posts::Postgame.new(@row, subreddit: @subreddit).create!
      end

      def game_thread_flair(type)
        @subreddit.options.dig('game_threads', 'flair', type)
      end

      def template_for(type)
        Template::GameThread.new(
          subreddit: @subreddit,
          game_pk: @game_pk,
          post_id: @post_id,
          type: type,
          title: @title
        )
      end
    end
  end
end

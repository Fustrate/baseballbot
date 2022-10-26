# frozen_string_literal: true

class Baseballbot
  class Subreddit
    attr_reader :id, :account, :name, :timezone, :options, :bot

    def initialize(row, bot:, account:)
      @bot = bot

      @id = row['id'].to_i
      @name = row['name']
      @team_id = row['team_id']
      @account = account

      @submissions = {}
      @options = JSON.parse(row['options'])

      @timezone = Baseballbot::Utility.parse_time_zone options['timezone']
    end

    def team
      @team ||= @bot.api.team(@team_id) if @team_id
    end

    def code = team&.abbreviation

    def now
      @now ||= Baseballbot::Utility.parse_time(Time.now.utc, in_time_zone: @timezone)
    end

    def off_today?
      @bot.api.schedule(
        sportId: 1,
        teamId: @team_id,
        date: Time.now.strftime('%m/%d/%Y'),
        eventTypes: 'primary',
        scheduleTypes: 'games'
      )['totalGames'].zero?
    end

    # --------------------------------------------------------------------------
    # Miscellaneous
    # --------------------------------------------------------------------------

    def sticky_game_threads? = @options.dig('game_threads', 'sticky') != false

    def subreddit
      @subreddit ||= @bot.session.subreddit(@name)
    end

    def code_to_subreddit_name(code)
      name = @options.dig('subreddits', code.upcase) || @bot.default_subreddit(code)

      @options.dig('subreddits', 'downcase') ? name.downcase : name
    end

    def settings
      return @settings if @settings

      @bot.with_reddit_account(@account.name) do
        @settings = subreddit.settings
      end
    end

    # Update settings for the current subreddit
    #
    # @param new_settings [Hash] new settings to apply to the subreddit
    def modify_settings(**new_settings)
      raise 'Sidebar is blank.' if new_settings.key?(:description) && new_settings[:description].strip.empty?

      @bot.with_reddit_account(@account.name) do
        response = subreddit.modify_settings(**new_settings)

        log_errors response.body.dig(:json, :errors), new_settings

        log_action 'Updated settings', data: new_settings
      end
    end

    # Submit a post to reddit in the current subreddit
    #
    # @param title [String] the title of the submission to create
    # @param text [String] the markdown body of the submission to create
    # @param flair_id [String] the UUID of the flair template to use
    #
    # @return [Redd::Models::Submission] the successfully created submission
    #
    # @todo Restore ability to pass captcha
    def submit(title:, text:, flair_id: nil)
      @bot.with_reddit_account(@account.name) do
        subreddit.submit title, text:, flair_id:, sendreplies: false
      end
    end

    def edit(id:, body: nil)
      @bot.with_reddit_account(@account.name) do
        load_submission(id:).edit(body)
      end
    end

    # Load a submission from reddit by its id
    #
    # @param id [String] an id to load
    #
    # @return [Redd::Models::Submission] the submission, if found
    #
    # @raise [RuntimeError] if a submission with this id does not exist
    def load_submission(id:)
      return @submissions[id] if @submissions[id]

      @bot.with_reddit_account(@account.name) do
        submission = @bot.session.from_ids("t3_#{id}")&.first

        raise "Unable to load post #{id}." unless submission

        @submissions[id] = submission
      end
    end

    def template_for(type)
      rows = @bot.db.exec_params(<<~SQL, [@id, type])
        SELECT body
        FROM templates
        WHERE subreddit_id = $1 AND type = $2
      SQL

      raise "/r/#{@name} does not have a #{type} template." if rows.count < 1

      rows[0]['body']
    end

    # --------------------------------------------------------------------------
    # Logging
    # --------------------------------------------------------------------------

    def log_errors(errors, _new_settings)
      return unless errors&.count&.positive?

      errors.each do |error|
        log_action 'Sidebar update error', data: { error: }

        # if error[0] == 'TOO_LONG' && error[1] =~ /max: \d+/
        #   # TODO: Message the moderators of the subreddit to tell them their sidebar is X characters too long.
        # end
      end
    end

    def log_action(action, note: '', data: {})
      @bot.log_action(
        subject_type: 'Subreddit',
        subject_id: @id,
        action:,
        note:,
        data:
      )
    end
  end
end

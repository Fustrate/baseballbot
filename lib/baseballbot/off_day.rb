# frozen_string_literal: true

class Baseballbot
  module OffDay
    UNPOSTED_CONDITIONS = <<~SQL
      options['off_day']['enabled']::boolean IS TRUE
        AND (options['off_day']['last_run_at'] IS NULL OR DATE(options['off_day']['last_run_at']::text) < CURRENT_DATE)
        AND (CURRENT_DATE + options['off_day']['post_at']::text::interval) < NOW() AT TIME ZONE (options->>'timezone')
    SQL

    def post_off_day_threads!(names: [])
      names = names.map(&:downcase)

      unposted_subreddits.each do |row|
        next unless names.empty? || names.include?(row[:name].downcase)

        post_off_day_thread! name: row[:name]
      end
    end

    def unposted_subreddits
      Baseballbot::Models::Subreddit
        .with_unposted_off_day_thread
        .order(:name)
        .all
    end

    def post_off_day_thread!(name:)
      Honeybadger.context(subreddit: name)

      subreddit = name_to_subreddit(name)

      off_day_check_was_run!(subreddit)

      Baseballbot::Posts::OffDay.new(subreddit:).create! if off_today?(subreddit)
    rescue => e
      Honeybadger.notify(e)
    end

    def off_day_check_was_run!(subreddit)
      # Why yes, calling json function via the Sequel gem is super easy and didn't take 27 tries to figure out.
      Baseballbot::Models::Subreddit.where(id: subreddit.id).update(
        options: Sequel.pg_jsonb_op(:options)
          .set(%w[off_day last_run_at], Sequel.lit(%('"#{Time.now.strftime('%F %T')}"'::jsonb)))
      )
    end

    protected

    def off_today?(subreddit)
      date = Baseballbot::Utility.parse_time(Time.now.utc, in_time_zone: subreddit.timezone).strftime('%m/%d/%Y')

      api.schedule(
        sportId: 1,
        teamId: subreddit.team.id,
        date:,
        calendarTypes: 'PRIMARY',
        scheduleTypes: 'GAMESCHEDULE'
      )['totalGames'].zero?
    end
  end
end

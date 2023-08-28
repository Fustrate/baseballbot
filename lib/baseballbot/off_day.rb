# frozen_string_literal: true

class Baseballbot
  module OffDay
    UNPOSTED_OFF_DAY_QUERY = <<~SQL
      SELECT name
      FROM subreddits
      WHERE options['off_day']['enabled']::boolean IS TRUE
      AND (options['off_day']['last_run_at'] IS NULL OR DATE(options['off_day']['last_run_at']::text) < CURRENT_DATE)
      AND ((CURRENT_DATE + options['off_day']['post_at']::text::interval) < NOW() AT TIME ZONE (options->>'timezone'))
      ORDER BY name ASC
    SQL

    def post_off_day_threads!(names: [])
      names = names.map(&:downcase)

      db.exec(UNPOSTED_OFF_DAY_QUERY).each do |row|
        next unless names.empty? || names.include?(row['name'].downcase)

        post_off_day_thread! name: row['name']
      end
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
      subreddit.options['off_day']['last_run_at'] = Time.now.strftime('%F %T')

      db.exec_params 'UPDATE subreddits SET options = $1 WHERE id = $2', [JSON.dump(subreddit.options), subreddit.id]
    end

    protected

    def off_today?(subreddit)
      date = Baseballbot::Utility.parse_time(Time.now.utc, in_time_zone: subreddit.timezone).strftime('%m/%d/%Y')

      api.schedule(
        sportId: 1,
        teamId: subreddit.team_id,
        date:,
        eventTypes: 'primary',
        scheduleTypes: 'games'
      )['totalGames'].zero?
    end
  end
end

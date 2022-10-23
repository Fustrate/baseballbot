# frozen_string_literal: true

require_relative 'default_bot'

class SyncModerators < DefaultBot
  def initialize(*subreddit_names)
    super(purpose: 'Sync Moderators')

    use_account 'BaseballBot'

    @subreddit_names = subreddit_names.map(&:downcase)
  end

  def run = subreddits.each_value { process_subreddit(_1) }

  protected

  def skip_subreddit?(name) = @subreddit_names.any? && !@subreddit_names.include?(name.downcase)

  def process_subreddit(subreddit)
    return if skip_subreddit?(subreddit.name)

    @subreddit = subreddit
    @mod_names = moderator_names

    reset_moderator_names

    remove_unmodded_users

    add_modded_users

    sleep 3
  rescue Redd::Errors::Forbidden
    # BaseballBot can't access /r/troxellophilus
    nil
  end

  def moderator_names
    # This can be filtered on :mod_permissions as well if necessary
    @subreddit.subreddit.moderators.map { _1[:name].downcase }
  end

  def reset_moderator_names
    names_sql_array = %({"#{@mod_names.join('","')}"})

    db.exec_params(<<~SQL, [names_sql_array, @subreddit.id])
      UPDATE subreddits SET moderators = $1 WHERE id = $2
    SQL
  end

  def remove_unmodded_users
    remove_ids = user_ids_to_remove

    return if remove_ids.none?

    db.exec_params(<<~SQL, [@subreddit.id, *remove_ids])
      DELETE FROM subreddits_users
      WHERE subreddit_id = $1
        AND user_id IN ($#{(2...(2 + remove_ids.length)).to_a.join(', $')})
    SQL
  end

  def user_ids_to_remove
    existing_relations[@subreddit.id]
      .reject { @mod_names.include?(_1['username']) }
      .map { _1['user_id'].to_i }
  end

  def add_modded_users
    mod_user_ids = db.exec_params(<<~SQL, [@subreddit.id, *@mod_names]).to_a.map { _1['id'] }
      SELECT id
      FROM users
        LEFT JOIN subreddits_users ON (subreddit_id = $1 AND user_id = users.id)
      WHERE user_id IS NULL AND username IN ($#{(2...(2 + @mod_names.length)).to_a.join(', $')})
    SQL

    mod_user_ids.each { add_modded_user(_1) }
  end

  def add_modded_user(user_id)
    db.exec_params(<<~SQL, [@subreddit.id, user_id.to_i])
      INSERT INTO subreddits_users (subreddit_id, user_id)
      VALUES ($1, $2)
    SQL
  end

  def existing_relations
    @existing_relations ||= begin
      rows = db.exec_params(<<~SQL).to_a
        SELECT subreddit_id, user_id, LOWER(users.username) AS username
        FROM subreddits_users
        LEFT JOIN subreddits ON (subreddits.id = subreddit_id)
        LEFT JOIN users ON (users.id = user_id)
      SQL

      rows.group_by { _1['subreddit_id'].to_i }.tap { _1.default = [] }
    end
  end
end

SyncModerators.new(*ARGV).run

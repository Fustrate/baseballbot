# frozen_string_literal: true

require_relative 'default_bot'

class SyncModerators < DefaultBot
  def initialize(subreddits: [])
    super(purpose: 'Sync Moderators')

    use_bot 'BaseballBot'

    @subreddit_names = subreddits.map(&:downcase)
  end

  def run = subreddits.each_value { process_subreddit(it) }

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
    @subreddit.subreddit.moderators.map { it[:name].downcase }
  end

  def reset_moderator_names
    sequel[:subreddits]
      .where(id: @subreddit.id)
      .update(moderators: Sequel.pg_array(@mod_names))
  end

  def remove_unmodded_users
    remove_ids = user_ids_to_remove

    return if remove_ids.none?

    sequel[:subreddits_users]
      .where(subreddit_id: @subreddit.id)
      .where(user_id: remove_ids)
      .delete
  end

  def user_ids_to_remove
    existing_relations[@subreddit.id]
      .reject { @mod_names.include?(it[:username]) }
      .map { it[:user_id].to_i }
  end

  def add_modded_users
    mod_user_ids = sequel[:users]
      .left_join(:subreddits_users, subreddit_id: @subreddit.id, user_id: :id)
      .where(subreddits_users__user_id: nil)
      .where(username: @mod_names)
      .select(:id)
      .all
      .map { it[:id] }

    mod_user_ids.each { add_modded_user(it) }
  end

  def add_modded_user(user_id)
    sequel[:subreddits_users].insert(subreddit_id: @subreddit.id, user_id: user_id.to_i)
  end

  def existing_relations
    @existing_relations ||= begin
      rows = sequel[:subreddits_users]
        .join(:subreddits, id: :subreddit_id)
        .join(:users, id: Sequel.lit('subreddits_users.user_id'))
        .select(:subreddit_id, :user_id, Sequel.function(:lower, :username).as(:username))
        .all

      rows.group_by { it[:subreddit_id].to_i }.tap { it.default = [] }
    end
  end
end

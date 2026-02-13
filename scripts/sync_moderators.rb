# frozen_string_literal: true

require_relative 'default_bot'

class SyncModerators < DefaultBot
  EXCLUDE_BOTS = %w[
    automoderator baseballflair botdefense comment-nuke discord-send duplicatedestroyer floodassistant modmail-userinfo
    modmailtodiscord repostsleuthbot trendingtattler
  ].freeze

  def initialize(subreddits: [])
    super(purpose: 'Sync Moderators')

    use_bot 'BaseballBot'

    @subreddit_names = subreddits.map(&:downcase)
  end

  def run = subreddits.each_value { process_subreddit(it) }

  protected

  def skip_subreddit?(name) = @subreddit_names.any? && !@subreddit_names.include?(name.downcase)

  def process_subreddit(subreddit)
    reset_moderator_names(subreddit)

    sleep 3
  rescue Redd::Errors::Forbidden
    # BaseballBot can't access this subreddit, likely because it's private.
    nil
  end

  def reset_moderator_names(subreddit)
    return if skip_subreddit?(subreddit.name)

    # If you have posts and/or config permissions, you're likely allowed to administrate this subreddit's game threads.
    moderator_names = subreddit.subreddit.moderators
      .filter { it[:mod_permissions].intersect?(%w[all posts config]) }
      .map { it[:name].downcase }
      .reject { EXCLUDE_BOTS.include?(it) }

    Baseballbot::Models::Subreddit
      .where(id: subreddit.id)
      .update(moderators: Sequel.pg_array(moderator_names))
  end
end

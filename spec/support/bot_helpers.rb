# frozen_string_literal: true

module BotHelpers
  def default_bot
    @default_bot ||= Baseballbot.new(user_agent: 'Baseballbot Tests')
  end

  def default_subreddit
    @default_subreddit ||= Baseballbot::Subreddit.new(
      { name: 'dodgers', team_code: 'LAD', team_id: 119, options: {} },
      bot: default_bot,
      bot_account: Baseballbot::Bot.new(bot: default_bot, name: 'RSpecTestBot', access: '')
    )
  end
end

# frozen_string_literal: true

module BotHelpers
  GAME_PKS = {
    in_progress: 715_730,
    final: 634_555,
    preview: 662_573
  }.freeze

  def default_bot
    @default_bot ||= Baseballbot.new(user_agent: 'Baseballbot Tests')
  end

  def default_subreddit
    @default_subreddit ||= Baseballbot::Subreddit.new(
      { 'name' => 'dodgers', 'team_code' => 'LAD', 'team_id' => 119, 'options' => '{}' },
      bot: default_bot,
      bot_account: Baseballbot::Bot.new(bot: default_bot, name: 'RSpecTestBot', access: '')
    )
  end

  def game_thread_template(status, title: 'Test', type: 'game_thread', body: '')
    allow(default_subreddit).to receive(:template_for).with('game_thread').and_return body

    Baseballbot::Templates::GameThread.new(subreddit: default_subreddit, game_pk: GAME_PKS[status], title:, type:)
  end
end

# frozen_string_literal: true

module BotHelpers
  GAME_PKS = {
    in_progress: 715_730,
    final: 634_555,
    preview: 662_573
  }.freeze

  def default_bot = Baseballbot.new(user_agent: 'Baseballbot Tests')

  def r_dodgers
    bot = default_bot

    Baseballbot::Subreddit.new(
      { 'name' => 'dodgers', 'team_code' => 'LAD', 'team_id' => 119, 'options' => '{}' },
      bot:,
      account: (Baseballbot::Account.new bot:, name: 'RSpecTestBot', access: '')
    ).tap do |sub|
      allow(sub).to receive(:template_for).with('game_thread').and_return ''
    end
  end

  def game_thread_template(status)
    Baseballbot::Templates::GameThread.new(
      subreddit: r_dodgers,
      game_pk: GAME_PKS[status],
      title: 'Test',
      type: 'game_thread'
    )
  end
end

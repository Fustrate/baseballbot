# frozen_string_literal: true

module BotHelpers
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

  def game_thread_template(game_pk:)
    Baseballbot::Template::GameThread.new(subreddit: r_dodgers, game_pk:, title: 'Test', type: 'game_thread')
  end
end

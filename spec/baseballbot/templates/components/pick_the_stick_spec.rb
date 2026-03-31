# frozen_string_literal: true

RSpec.describe Baseballbot::Templates::Components::PickTheStick do
  let(:bot) { Baseballbot.new(user_agent: 'Baseballbot Tests') }
  let(:subreddit) do
    Baseballbot::Subreddit.new(
      { name: 'dodgers', team_code: 'LAD', team_id: 119, options: {} },
      bot:,
      bot_account: Baseballbot::Bot.new(bot:, name: 'RSpecTestBot', access: '')
    )
  end

  before { stub_requests! with_response: true }

  describe '#to_s' do
    it 'returns a fallback markdown link when team is not configured' do
      no_team_subreddit = Baseballbot::Subreddit.new(
        { name: 'baseball', team_id: nil, options: {} },
        bot:,
        bot_account: Baseballbot::Bot.new(bot:, name: 'RSpecTestBot', access: '')
      )

      expect(described_class.new(no_team_subreddit).to_s).to eq '[](/pickthestick "Team not configured")'
    end

    it 'renders a standings table from pick the stick data' do
      component = described_class.new(subreddit)

      data = (1..11).map do |rank|
        {
          'ranking' => rank,
          'username' => "user#{rank}",
          'points' => 100 - rank,
          'total_picks' => 20 + rank,
          'position_change' => "+#{rank}"
        }
      end

      allow(component).to receive(:pick_the_stick_data).and_return(data)

      output = component.to_s

      expect(output).to include('|Rank|User|Points|Total Picks|Position Change|')
      expect(output).to include('|:-:|:-:|:-:|:-:|:-:|')
      expect(output).to include('|1|user1|99|21|+1|')
      expect(output).to include('|10|user10|90|30|+10|')
      expect(output).not_to include('|11|user11|89|31|+11|')
    end
  end
end

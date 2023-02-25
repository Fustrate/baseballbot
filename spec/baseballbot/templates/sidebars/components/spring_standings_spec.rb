# frozen_string_literal: true

RSpec.describe Baseballbot::Templates::Sidebars::Components::SpringStandings do
  let(:bot) { Baseballbot.new(user_agent: 'Baseballbot Tests') }
  let(:subreddit) do
    Baseballbot::Subreddit.new(
      { 'name' => 'dodgers', 'team_code' => 'LAD', 'team_id' => 119, 'options' => '{}' },
      bot:,
      account: (Baseballbot::Account.new bot:, name: 'RSpecTestBot', access: '')
    )
  end

  before { stub_requests! with_response: true }

  describe '#spring_standings' do
    it 'generates the Cactus League standings' do
      def standings_row(team)
        "|[][#{team.abbreviation}]|#{team.wins}|#{team.losses}|#{team.percent}|#{team.games_back}|#{team.last_ten}|"
      end

      expect(described_class.new(subreddit).map { standings_row(_1) }.join("\n")).to eq(<<~MARKDOWN.strip)
        |[][LAA]|11|6|.647|-|7-3|
        |[][TEX]|10|6|.625|-|5-4|
        |[][CHC]|11|7|.611|-|7-3|
        |[][CIN]|10|7|.588|-|5-4|
        |[][SEA]|9|7|.563|-|6-4|
        |[][SF]|8|7|.533|-|6-2|
        |[][AZ]|11|10|.524|-|6-4|
        |[][KC]|8|8|.500|-|3-7|
        |[][CWS]|9|10|.474|-|4-6|
        |[][COL]|8|9|.471|-|3-5|
        |[][MIL]|7|9|.438|-|4-5|
        |[][SD]|7|9|.438|-|5-5|
        |[][CLE]|7|12|.368|-|2-8|
        |[][LAD]|5|9|.357|-|4-6|
        |[][OAK]|5|10|.333|-|3-5|
      MARKDOWN
    end
  end
end

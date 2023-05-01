# frozen_string_literal: true

RSpec.describe Baseballbot::Templates::Components::DivisionStandings do
  let(:bot) { Baseballbot.new(user_agent: 'Baseballbot Tests') }
  let(:subreddit) do
    Baseballbot::Subreddit.new(
      { 'name' => 'dodgers', 'team_code' => 'LAD', 'team_id' => 119, 'options' => '{}' },
      bot:,
      account: (Baseballbot::Account.new bot:, name: 'RSpecTestBot', access: '')
    )
  end

  before { stub_requests! with_response: true }

  describe '#division_standings' do
    it 'generates the NL West standings' do
      def standings_row(team)
        "|[][#{team.abbreviation}]|#{team.wins}|#{team.losses}|#{team.percent}|#{team.games_back}|#{team.last_ten}|"
      end

      expect(described_class.new(subreddit).map { standings_row(_1) }.join("\n")).to eq(<<~MARKDOWN.strip)
        |[][LAD]|111|51|.685|-|6-4|
        |[][SD]|89|73|.549|22|5-5|
        |[][SF]|81|81|.500|30|7-3|
        |[][AZ]|74|88|.457|37|4-6|
        |[][COL]|68|94|.420|43|3-7|
      MARKDOWN
    end
  end
end

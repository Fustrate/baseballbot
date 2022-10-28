# frozen_string_literal: true

RSpec.describe Baseballbot::Templates::Sidebars::Components::LeagueStandings do
  let(:bot) { Baseballbot.new(user_agent: 'Baseballbot Tests') }
  let(:subreddit) do
    Baseballbot::Subreddit.new(
      { 'name' => 'dodgers', 'team_code' => 'LAD', 'team_id' => 119, 'options' => '{}' },
      bot:,
      account: (Baseballbot::Account.new bot:, name: 'RSpecTestBot', access: '')
    )
  end

  before { stub_requests! with_response: true }

  describe '#league_standings' do
    it 'generates /r/baseball\'s standings tables' do
      expect(described_class.new(subreddit).to_s).to eq(<<~MARKDOWN.strip)
        # 2022 Standings

        Click a team's logo to visit their subreddit

        ## National League

        |West|Central|East|
        |:-:|:-:|:-:|
        |[**111-51**][LAD]|[**93-69**][STL]|[**101-61**][ATL]|
        |[89-73](/r/Padres "WC2")|[86-76][MIL]|[101-61](/r/NewYorkMets "WC1")|
        |[81-81][SF]|[74-88][CHC]|[87-75](/r/Phillies "WC3")|
        |[74-88][ARI]|[62-100][CIN]|[69-93][MIA]|
        |[68-94][COL]|[62-100][PIT]|[55-107][WSH]|

        ## American League

        |West|Central|East|
        |:-:|:-:|:-:|
        |[**106-56**][HOU]|[**92-70**][CLE]|[**99-63**][NYY]|
        |[90-72](/r/Mariners "WC2")|[81-81][CWS]|[92-70](/r/TorontoBlueJays "WC1")|
        |[73-89][LAA]|[78-84][MIN]|[86-76](/r/TampaBayRays "WC3")|
        |[68-94][TEX]|[66-96][DET]|[83-79][BAL]|
        |[60-102][OAK]|[65-97][KC]|[78-84][BOS]|
      MARKDOWN
    end
  end
end

# frozen_string_literal: true

RSpec.describe Baseballbot::Templates::Components::LeagueStandings do
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
        |[LAD][LAD] [**111-51**](/r/Dodgers)|[STL][STL] [**93-69**](/r/Cardinals)|[ATL][ATL] [**101-61**](/r/Braves)|
        |[SD](/r/Padres#flair "WC2") [89-73](/r/Padres)|[MIL][MIL] [86-76](/r/Brewers)|[NYM](/r/NewYorkMets#flair "WC1") [101-61](/r/NewYorkMets)|
        |[SF][SF] [81-81](/r/SFGiants)|[CHC][CHC] [74-88](/r/CHICubs)|[PHI](/r/Phillies#flair "WC3") [87-75](/r/Phillies)|
        |[AZ][AZ] [74-88](/r/azdiamondbacks)|[CIN][CIN] [62-100](/r/Reds)|[MIA][MIA] [69-93](/r/MiamiMarlins)|
        |[COL][COL] [68-94](/r/ColoradoRockies)|[PIT][PIT] [62-100](/r/Buccos)|[WSH][WSH] [55-107](/r/Nationals)|

        ## American League

        |West|Central|East|
        |:-:|:-:|:-:|
        |[HOU][HOU] [**106-56**](/r/Astros)|[CLE][CLE] [**92-70**](/r/ClevelandGuardians)|[NYY][NYY] [**99-63**](/r/NYYankees)|
        |[SEA](/r/Mariners#flair "WC2") [90-72](/r/Mariners)|[CWS][CWS] [81-81](/r/WhiteSox)|[TOR](/r/TorontoBlueJays#flair "WC1") [92-70](/r/TorontoBlueJays)|
        |[LAA][LAA] [73-89](/r/AngelsBaseball)|[MIN][MIN] [78-84](/r/MinnesotaTwins)|[TB](/r/TampaBayRays#flair "WC3") [86-76](/r/TampaBayRays)|
        |[TEX][TEX] [68-94](/r/TexasRangers)|[DET][DET] [66-96](/r/MotorCityKitties)|[BAL][BAL] [83-79](/r/Orioles)|
        |[OAK][OAK] [60-102](/r/Athletics)|[KC][KC] [65-97](/r/KCRoyals)|[BOS][BOS] [78-84](/r/RedSox)|
      MARKDOWN
    end
  end
end

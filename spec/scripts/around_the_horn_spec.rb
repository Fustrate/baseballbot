# frozen_string_literal: true

require_relative '../../scripts/around_the_horn'

RSpec.describe AroundTheHorn do
  # pending

  before do
    stub_request(:post, 'https://www.reddit.com/api/v1/access_token')
      .to_return(status: 200, body: '{"access_token":"abc123","expires_in":3600}')

    stub_request(:get, 'https://oauth.reddit.com/r/baseball/wiki/ath?api_type=json&raw_json=1').to_return(
      status: 200,
      body: '{"data":{"content_md":"Dummy\n----\nHello\n\n[](/todays_games)[](/todays_games)\n\nWorld\n----\nDummy"}}'
    )

    stub_requests! with_response: true
  end

  let(:ath) { described_class.new }

  it 'has the proper post title' do
    expect(ath.send(:post_title)).to eq '[General Discussion] Around the Horn & Game Thread Index - 7/4/22'
  end

  it 'has the proper initial body' do
    expect(ath.send(:initial_body).strip).to eq <<~MARKDOWN.strip
      Hello

      [](/todays_games)[](/todays_games)

      World
    MARKDOWN
  end

  it 'generates the initial post' do
    wiki_content = "Hello\n\n[](/todays_games)[](/todays_games)\n\nWorld"

    expect(ath.send(:update_todays_games_in, wiki_content).strip).to eq <<~MARKDOWN.strip
      Hello

      [](/todays_games)
      # Monday's Games

      |Away|Score|Home|Score|Status|National|GDTs|
      |-|:-:|-|:-:|:-:|-|-|
      |[MIA](/r/MiamiMarlins)|**3**|[WSH](/r/Nationals)|*2*|[F/10](https://www.mlb.com/gameday/662541)| ||
      |[TEX](/r/TexasRangers)|*6*|[BAL](/r/Orioles)|**7**|[F/10](https://www.mlb.com/gameday/661073)| ||
      |[CLE](/r/ClevelandGuardians)|*1*|[DET](/r/MotorCityKitties)|**4**|[F](https://www.mlb.com/gameday/662906)| ||
      |[CLE](/r/ClevelandGuardians)|*3*|[DET](/r/MotorCityKitties)|**5**|[F](https://www.mlb.com/gameday/662841)| ||
      |[TB](/r/TampaBayRays)|*0*|[BOS](/r/RedSox)|**4**|[F](https://www.mlb.com/gameday/663251)| ||
      |[KC](/r/KCRoyals)|*6*|[HOU](/r/Astros)|**7**|[F](https://www.mlb.com/gameday/662874)| ||
      |[CHC](/r/CHICubs)|*2*|[MIL](/r/Brewers)|**5**|[F/10](https://www.mlb.com/gameday/661181)| ||
      |[SF](/r/SFGiants)|*3*|[AZ](/r/azdiamondbacks)|**8**|[F](https://www.mlb.com/gameday/663343)| ||
      |[NYM](/r/NewYorkMets)|**7**|[CIN](/r/Reds)|*4*|[F](https://www.mlb.com/gameday/663036)| ||
      |[SEA](/r/Mariners)|**8**|[SD](/r/Padres)|*2*|[F](https://www.mlb.com/gameday/662270)| ||
      |[STL](/r/Cardinals)|*3*|[ATL](/r/Braves)|**6**|[F](https://www.mlb.com/gameday/661511)| ||
      |[MIN](/r/MinnesotaTwins)|**6**|[CWS](/r/WhiteSox)|*3*|[F/10](https://www.mlb.com/gameday/661452)| ||
      |[TOR](/r/TorontoBlueJays)|*1*|[OAK](/r/baseball)|**5**|[F](https://www.mlb.com/gameday/662355)| ||
      |[COL](/r/ColoradoRockies)|*3*|[LAD](/r/Dodgers)|**5**|[F](https://www.mlb.com/gameday/662732)| ||

      All game times are Eastern. [Updated](https://baseballbot.io) 7/4 at 9:28 AM PDT




      [](/todays_games)

      World
    MARKDOWN
  end
end

# frozen_string_literal: true

require_relative '../../scripts/around_the_horn'

RSpec.describe AroundTheHorn do
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
    expect(ath.send(:post_title)).to eq '[General Discussion] Around the Horn - 7/4/22'
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

      |Away|Score|Home|Score|Status|National|
      |-|:-:|-|:-:|:-:|-|
      |[][MIA]|**3**|[][WSH]|*2*|[F/10](https://www.mlb.com/gameday/662541)| |
      |[][TEX]|*6*|[][BAL]|**7**|[F/10](https://www.mlb.com/gameday/661073)| |
      |[][CLE]|*1*|[][DET]|**4**|[F](https://www.mlb.com/gameday/662906)| |
      |[][CLE]|*3*|[][DET]|**5**|[F](https://www.mlb.com/gameday/662841)| |
      |[][TB]|*0*|[][BOS]|**4**|[F](https://www.mlb.com/gameday/663251)| |
      |[][KC]|*6*|[][HOU]|**7**|[F](https://www.mlb.com/gameday/662874)| |
      |[][CHC]|*2*|[][MIL]|**5**|[F/10](https://www.mlb.com/gameday/661181)| |
      |[][SF]|*3*|[][ARI]|**8**|[F](https://www.mlb.com/gameday/663343)| |
      |[][NYM]|**7**|[][CIN]|*4*|[F](https://www.mlb.com/gameday/663036)| |
      |[][SEA]|**8**|[][SD]|*2*|[F](https://www.mlb.com/gameday/662270)| |
      |[][STL]|*3*|[][ATL]|**6**|[F](https://www.mlb.com/gameday/661511)| |
      |[][MIN]|**6**|[][CWS]|*3*|[F/10](https://www.mlb.com/gameday/661452)| |
      |[][TOR]|*1*|[][OAK]|**5**|[F](https://www.mlb.com/gameday/662355)| |
      |[][COL]|*3*|[][LAD]|**5**|[F](https://www.mlb.com/gameday/662732)| |

      ^(★)Game Thread. All game times are Eastern. [Updated](https://baseballbot.io) 7/4 at 5:28 AM




      [](/todays_games)

      World
    MARKDOWN
  end
end

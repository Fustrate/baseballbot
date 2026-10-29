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
    wiki_content = 'Hello World'

    expect(ath.send(:update_todays_games_in, wiki_content).strip).to eq <<~MARKDOWN.strip
      Hello World
    MARKDOWN
  end
end

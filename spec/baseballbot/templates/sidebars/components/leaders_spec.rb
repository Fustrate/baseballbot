# frozen_string_literal: true

RSpec.describe Baseballbot::Templates::Sidebars::Components::Leaders do
  let(:bot) { Baseballbot.new(user_agent: 'Baseballbot Tests') }
  let(:subreddit) do
    Baseballbot::Subreddit.new(
      { 'name' => 'dodgers', 'team_code' => 'LAD', 'team_id' => 119, 'options' => '{}' },
      bot:,
      account: (Baseballbot::Account.new bot:, name: 'RSpecTestBot', access: '')
    )
  end

  before { stub_requests! with_response: true }

  describe '#hitter_stats' do
    it 'loads basic hitter stats' do
      expect(described_class.new(subreddit).hitter_stats).to eq(
        'avg' => [{ name: 'F Freeman', value: '.322' }],
        'bb' => [{ name: 'M Muncy', value: 57 }],
        'h' => [{ name: 'F Freeman', value: 120 }],
        'hr' => [{ name: 'M Betts', value: 22 }],
        'obp' => [{ name: 'F Freeman', value: '.398' }],
        'ops' => [{ name: 'F Freeman', value: '.937' }],
        'r' => [{ name: 'M Betts', value: 67 }],
        'rbi' => [{ name: 'T Turner', value: 69 }],
        'sb' => [{ name: 'T Turner', value: 17 }],
        'slg' => [{ name: 'F Freeman', value: '.539' }],
        'xbh' => [{ name: 'F Freeman', value: 49 }]
      )
    end
  end

  describe '#hitter_stats_table' do
    it 'generates a markdown table' do
      expect(described_class.new(subreddit).hitter_stats_table(stats: %w[avg bb h hr obp ops r rbi sb slg xbh]))
        .to eq(<<~MARKDOWN.strip)
          |Stat|Player|Total|
          |-|-|-|
          |AVG|F Freeman|.322|
          |BB|M Muncy|57|
          |H|F Freeman|120|
          |HR|M Betts|22|
          |OBP|F Freeman|.398|
          |OPS|F Freeman|.937|
          |R|M Betts|67|
          |RBI|T Turner|69|
          |SB|T Turner|17|
          |SLG|F Freeman|.539|
          |XBH|F Freeman|49|
        MARKDOWN
    end
  end

  describe '#pitcher_stats' do
    it 'loads basic pitcher stats' do
      expect(described_class.new(subreddit).pitcher_stats).to eq(
        'avg' => [{ name: 'T Gonsolin', value: '.174' }],
        'era' => [{ name: 'T Gonsolin', value: '2.260' }],
        'hld' => [{ name: 'E Phillips', value: 11 }],
        'ip' => [{ name: 'T Anderson', value: '103.1' }],
        'so' => [{ name: 'J Urías', value: 99 }],
        'sv' => [{ name: 'C Kimbrel', value: 17 }],
        'w' => [{ name: 'T Gonsolin', value: 11 }],
        'whip' => [{ name: 'T Gonsolin', value: '.880' }]
      )
    end
  end

  describe '#pitcher_stats_table' do
    it 'generates a markdown table' do
      expect(described_class.new(subreddit).pitcher_stats_table(stats: %w[avg era hld ip so sv w whip]))
        .to eq(<<~MARKDOWN.strip)
          |Stat|Player|Total|
          |-|-|-|
          |AVG|T Gonsolin|.174|
          |ERA|T Gonsolin|2.260|
          |HLD|E Phillips|11|
          |IP|T Anderson|103.1|
          |SO|J Urías|99|
          |SV|C Kimbrel|17|
          |W|T Gonsolin|11|
          |WHIP|T Gonsolin|.880|
        MARKDOWN
    end
  end
end

# frozen_string_literal: true

RSpec.describe Baseballbot::Template::GameThread::Links do
  let(:template) { game_thread_template(game_pk: 662_573) }

  before do
    stub_requests! with_response: true
  end

  describe '#gameday_link' do
    it 'generates a gameday link' do
      expect(template.gameday_link).to eq 'https://www.mlb.com/gameday/662573'
    end

    it 'generates a gameday preview link' do
      expect(template.gameday_link(mode: 'preview')).to eq 'https://www.mlb.com/gameday/662573/preview'
    end
  end

  describe '#player_link' do
    it 'generates a markdown link to a normal player hash' do
      expect(template.player_link({ 'boxscoreName' => 'Smith, W.D.', 'id' => 420 }))
        .to eq '[Smith, W.D.](https://www.mlb.com/player/420)'
    end

    it 'generates a markdown link to a player with a complicated hash' do
      expect(template.player_link({ 'name' => { 'boxscore' => 'Smith, W.D.' }, 'person' => { 'id' => 420 } }))
        .to eq '[Smith, W.D.](https://www.mlb.com/player/420)'
    end
  end

  describe '#player_url' do
    it 'generates a link to a player by ID' do
      expect(template.player_url(8_675_309)).to eq 'https://www.mlb.com/player/8675309'
    end
  end

  describe '#game_graph_link' do
    it 'generates a Fangraphs link' do
      expect(template.game_graph_link)
        .to eq 'http://www.fangraphs.com/livewins.aspx?date=2022-07-26&team=Dodgers&dh=0&season=2022'
    end
  end

  describe '#savant_feed_link' do
    it 'generates a Baseball Savant feed link' do
      expect(template.savant_feed_link).to eq 'https://baseballsavant.mlb.com/gamefeed?gamePk=662573'
    end
  end

  describe '#thumbnail' do
    it 'generates a thumbnail markdown link' do
      expect(template.thumbnail).to eq '[](http://mlb.mlb.com/images/2017_ipad/684/wasla_684.jpg)'
    end
  end

  describe '#discord_link' do
    it 'uses the default /r/baseball discord link if none is set' do
      expect(template.discord_link).to eq 'https://discord.gg/rbaseball'
    end

    it 'uses a custom discord link if set' do
      template.instance_variable_get(:@subreddit).options[:discord_invite] = 'https://discordapp.com/invite/abc123'

      expect(template.discord_link).to eq 'https://discordapp.com/invite/abc123'
    end
  end
end

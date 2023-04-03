# frozen_string_literal: true

RSpec.describe Baseballbot::Templates::GameThreads::Links do
  let(:template) { game_thread_template(:preview) }

  before do
    stub_requests! with_response: true
  end

  describe '#gameday_link' do
    it 'generates a gameday link' do
      expect(template.gameday_link).to eq 'https://www.mlb.com/gameday/662573'
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
      template.instance_variable_get(:@subreddit).options['discord_invite'] = 'https://discordapp.com/invite/abc123'

      expect(template.discord_link).to eq 'https://discordapp.com/invite/abc123'
    end
  end
end

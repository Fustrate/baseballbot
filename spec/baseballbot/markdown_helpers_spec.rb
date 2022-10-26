# frozen_string_literal: true

class TestSubject
  include Baseballbot::MarkdownHelpers
end

RSpec.describe Baseballbot::MarkdownHelpers do
  let(:template) { TestSubject.new }

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
end

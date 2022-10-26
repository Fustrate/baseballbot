# frozen_string_literal: true

RSpec.describe Baseballbot::Templates::GameThreads::Decisions do
  before do
    stub_requests! with_response: true
  end

  describe '#decisions_section' do
    it 'generates a decisions section' do
      template = game_thread_template(:final)

      expect(template.decisions_section.to_s).to eq <<~MARKDOWN.strip
        ### Decisions

        |Winning Pitcher|Losing Pitcher|Save|
        |:-:|:-:|:-:|
        |Arrieta (2-0, 2.25 ERA)|Anderson, Ty (0-2, 5.23 ERA)|Kimbrel (2 SV, 0.00 ERA)|
      MARKDOWN
    end

    it 'does not output anything until the game has ended' do
      template = game_thread_template(:in_progress)

      expect(template.decisions_section.to_s).to be_nil
    end
  end
end

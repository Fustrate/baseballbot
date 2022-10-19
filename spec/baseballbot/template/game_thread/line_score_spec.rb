# frozen_string_literal: true

RSpec.describe Baseballbot::Template::GameThread::LineScore do
  before do
    stub_requests! with_response: true
  end

  describe '#line_score_section' do
    it 'generates a gameday link' do
      template = game_thread_template(game_pk: 715_730)

      expect(template.line_score_section).to eq <<~MARKDOWN
        ### Line Score - Bases loaded, 2 Outs, Bottom of the 5th

        | |1|2|3|4|5|6|7|8|9|R|H|E|LOB|
        |-|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
        |PHI|0|4|0|0|0|**4**|**5**|**0**|**2**|
        |SD|0|2|0|0|5|**7**|**9**|**1**|**1**|
      MARKDOWN
    end
  end
end

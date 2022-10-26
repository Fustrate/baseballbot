# frozen_string_literal: true

RSpec.describe Baseballbot::Templates::GameThreads::BoxScore do
  before do
    stub_requests! with_response: true
  end

  describe '#box_score_section' do
    it 'generates a box score' do
      expect(described_class.new(game_thread_template(:in_progress)).to_s).to eq <<~MARKDOWN.strip
        ### Box Score

        |**SD**| |AB|R|H|RBI|BB|SO|BA|
        |-|-|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
        |**LF**|[Profar](https://www.mlb.com/player/595777)|3|1|1|0|0|1|.258|
        |**RF**|[Soto, J](https://www.mlb.com/player/665742)|3|1|1|1|0|0|.235|
        |**3B**|[Machado, M](https://www.mlb.com/player/592518)|3|0|1|0|0|2|.265|
        |**2B**|[Cronenworth](https://www.mlb.com/player/630105)|2|1|0|0|0|2|.206|
        |**1B**|[Drury](https://www.mlb.com/player/592273)|3|1|2|3|0|0|.167|
        |**DH**|[Bell](https://www.mlb.com/player/605137)|3|1|2|2|0|1|.192|
        |**SS**|[Kim](https://www.mlb.com/player/673490)|2|1|1|0|1|0|.194|
        |**CF**|[Grisham](https://www.mlb.com/player/663757)|2|0|0|0|0|0|.308|
        |**C**|[Nola, Au](https://www.mlb.com/player/543592)|2|1|1|1|0|0|.346|

        |**SD**|IP|H|R|ER|BB|SO|P-S|ERA|
        |-|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
        |[Snell](https://www.mlb.com/player/605483 "Game Score: 52")|5.0|5|4|4|1|6|89-56|4.61|

        |**PHI**| |AB|R|H|RBI|BB|SO|BA|
        |-|-|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
        |**LF**|[Schwarber](https://www.mlb.com/player/656941)|2|0|0|1|1|0|.120|
        |**1B**|[Hoskins](https://www.mlb.com/player/656555)|3|0|0|0|0|1|.121|
        |**C**|[Realmuto](https://www.mlb.com/player/592663)|3|0|0|0|0|1|.194|
        |**DH**|[Harper](https://www.mlb.com/player/547180)|2|1|1|0|0|0|.414|
        |**RF**|[Castellanos, N](https://www.mlb.com/player/592206)|2|1|1|0|0|0|.214|
        |**3B**|[Bohm](https://www.mlb.com/player/664761)|2|1|1|1|0|1|.200|
        |**2B**|[Segura](https://www.mlb.com/player/516416)|2|0|0|0|0|1|.304|
        |**CF**|[Vierling](https://www.mlb.com/player/663837)|2|1|1|1|0|1|.250|
        |**SS**|[Sosa, E](https://www.mlb.com/player/624641)|2|0|1|1|0|1|.500|

        |**PHI**|IP|H|R|ER|BB|SO|P-S|ERA|
        |-|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
        |[Nola, Aa](https://www.mlb.com/player/605400 "Game Score: 34")|4.2|7|6|6|0|6|81-54|3.12|
        |[Hand](https://www.mlb.com/player/543272)|0.0|2|1|1|0|0|15-7|3.38|
        |[Bellatti](https://www.mlb.com/player/571479)|0.0|0|0|0|1|0|12-5|3.38|
      MARKDOWN
    end
  end
end

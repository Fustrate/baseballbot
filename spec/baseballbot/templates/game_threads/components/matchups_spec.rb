# frozen_string_literal: true

RSpec.describe Baseballbot::Templates::GameThreads::Components::Matchups do
  before do
    stub_requests! with_response: true
  end

  describe '#matchups_section' do
    it 'generates a matchups section' do
      expect(described_class.new(game_thread_template(:preview)).to_s).to eq <<~MARKDOWN.strip
        |LAD vs. Gray|AVG|OPS|AB|HR|RBI|K|
        |-|-|-|-|-|-|-|
        |Alberto|-|-|-|-|-|-|
        |Barnes, A|-|-|-|-|-|-|
        |Bellinger|.500|2.500|2|1|1|1|
        |Betts|.400|2.000|5|2|4|0|
        |Freeman, F|.000|.111|7|0|1|1|
        |Lamb|.000|.250|3|0|0|1|
        |Lux|.000|.500|2|0|0|0|
        |McKinstry|.167|.611|6|0|0|1|
        |Muncy|.000|.250|3|0|0|3|
        |Smith, W.D.|.200|.400|5|0|0|1|
        |Thompson, T|.500|1.167|2|0|0|1|
        |Turner|.500|1.429|14|1|3|4|
        |Turner, J|.000|.250|3|0|0|1|

        |WSH vs. White|AVG|OPS|AB|HR|RBI|K|
        |-|-|-|-|-|-|-|
        |Adrianza|.000|.000|1|0|0|1|
        |Barrera|-|-|-|-|-|-|
        |Bell|.750|1.750|4|0|2|0|
        |Cruz, N|-|-|-|-|-|-|
        |Escobar, A|-|-|-|-|-|-|
        |Franco|.000|.000|3|0|0|1|
        |García Jr., L|.667|2.000|3|0|0|0|
        |Hernandez, Y|.333|.666|3|0|1|1|
        |Hernández, C|.333|.666|3|0|0|1|
        |Robles|.667|1.334|3|0|0|0|
        |Ruiz, K|.000|.000|3|0|0|0|
        |Soto, J|.000|.200|4|0|0|0|
        |Thomas, L|.500|1.000|2|0|0|1|
      MARKDOWN
    end
  end
end

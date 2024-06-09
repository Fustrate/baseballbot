# frozen_string_literal: true

RSpec.describe Baseballbot::Templates::Sidebars::Components::Postseason do
  let(:calendar) { described_class.new(default_subreddit) }

  before { stub_requests! with_response: true }

  describe '#to_s' do
    it 'generates series info for the postseason' do
      expect(calendar.to_s).to eq(<<~MARKDOWN.strip)
        # 2022 Postseason

        ## AL Division Series
        | | | |
        |:-:|:-:|:-:|
        |[Orioles][BAL]|0-2|[Rangers][TEX]|
        |[Astros][HOU]|1-1|[Twins][MIN]|

        ## NL Division Series
        | | | |
        |:-:|:-:|:-:|
        |[Braves][ATL]|0-1|[Phillies][PHI]|
        |[Dodgers][LAD]|0-1|[D-backs][AZ]|

        ## AL Wild Card
        | | | |
        |:-:|:-:|:-:|
        |[Rangers][TEX]|**2**-0|[Rays][TB]|
        |[Blue Jays][TOR]|0-**2**|[Twins][MIN]|

        ## NL Wild Card
        | | | |
        |:-:|:-:|:-:|
        |[D-backs][AZ]|**2**-0|[Brewers][MIL]|
        |[Marlins][MIA]|0-**2**|[Phillies][PHI]|
      MARKDOWN
    end
  end
end

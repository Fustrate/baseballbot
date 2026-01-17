# frozen_string_literal: true

RSpec.describe Baseballbot::Templates::Sidebars::Components::Calendar do
  let(:bot) { Baseballbot.new(user_agent: 'Baseballbot Tests') }
  let(:subreddit) do
    Baseballbot::Subreddit.new(
      { name: 'dodgers', team_code: 'LAD', team_id: 119, options: {} },
      bot:,
      bot_account: Baseballbot::Bot.new(bot:, name: 'RSpecTestBot', access: '')
    )
  end

  before { stub_requests! with_response: true }

  describe '#calendar' do
    it 'generates a monthly calendar' do
      expect(described_class.new(subreddit).to_s).to eq(<<~MARKDOWN.strip)
        |S|M|T|W|T|F|S|
        |:-:|:-:|:-:|:-:|:-:|:-:|:-:|
        | | | | | |**^1 [](/r/Padres "Won 5-1")**|**^2 [](/r/Padres "Won 7-2")**|
        |**^3 [](/r/Padres "Lost 2-4")**|**^4 [](/r/ColoradoRockies "Won 5-3")**|**^5 [](/r/ColoradoRockies "Won 5-2")**|**^6 [](/r/ColoradoRockies "Won 2-1")**|**^7 [](/r/CHICubs "Won 5-3")**|**^8 [](/r/CHICubs "Won 4-3")**|**^9 [](/r/CHICubs "Won 4-2")**|
        |**^10 [](/r/CHICubs "Won 11-9")**|^11|*^12 [](/r/Cardinals "Lost 6-7")*|*^13 [](/r/Cardinals "Won 7-6")*|*^14 [](/r/Cardinals "Won 4-0")*|*^15 [](/r/AngelsBaseball "Won 9-1")*|*^16 [](/r/AngelsBaseball "Won 7-1")*|
        |^17|^18|^19|^20|**^21 [](/r/SFGiants "Won 9-6")**|**^22 [](/r/SFGiants "Won 5-1")**|**^23 [](/r/SFGiants "Won 4-2")**|
        |**^24 [](/r/SFGiants "Won 7-4")**|**^25 [](/r/Nationals "Lost 1-4")**|**^26 [](/r/Nationals "Lost 3-8")**|**^27 [](/r/Nationals "Won 7-1")**|*^28 [](/r/ColoradoRockies "Won 13-0")*|*^29 [](/r/ColoradoRockies "Won 5-4")*|*^30 [](/r/ColoradoRockies "Lost 3-5")*|
        |*^31 [](/r/ColoradoRockies "Won 7-3")*| | | | | | |
      MARKDOWN
    end
  end
end

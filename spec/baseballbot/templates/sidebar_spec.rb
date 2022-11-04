# frozen_string_literal: true

RSpec.describe Baseballbot::Templates::Sidebar do
  before do
    stub_requests! with_response: true
  end

  describe '#to_s' do
    it 'generates a dull template' do
      sidebar = described_class.new(subreddit: default_subreddit, body: <<~BODY.strip)
        Hello World
      BODY

      expect(sidebar.evaluated_body).to eq 'Hello World'
    end

    it 'adds a few blocks' do
      sidebar = described_class.new(subreddit: default_subreddit, body: <<~BODY.strip)
        <% hitters = hitter_stats(count: 3) %>
        <% pitchers = pitcher_stats(count: 3) %>
        # AL West Standings

        |Standings|W|L|PCT|GB|
        |:-:|:-:|:-:|:-:|:-:|
        <% division_standings.each do |team| %>
        |[<%= team.name %>](/r/<%= subreddit.code_to_subreddit_name(team.abbreviation) %>)|<%= team.wins %>|<%= team.losses %>|<%= team.percent %>|<%= team.games_back %>|
        <% end %>

        <%= updated_with_link %>

        # <%= @subreddit.now.strftime '%B' %> Schedule

        <%= calendar %>

        # Team Leaders

        ## Hitting

        |Name|OPS||Name|AVG|
        |-|-|-|-|-|
        <% [0,1,2].each do |n| %>
        |<%= (hitters['ops'][n] || { name: ' ', value: ' ' })&.values&.join('|') %>||<%= (hitters['avg'][n] || { name: ' ', value: ' ' }).values.join('|') %>|
        <% end %>

        |Name|HR||Name|RBI|
        |-|-|-|-|-|
        <% [0,1,2].each do |n| %>
        |<%= (hitters['hr'][n] || { name: ' ', value: ' ' })&.values&.join('|') %>||<%= (hitters['rbi'][n] || { name: ' ', value: ' ' }).values.join('|') %>|
        <% end %>

        ## Pitching

        |Name|ERA||Name|WHIP|
        |-|-|-|-|-|
        <% [0,1,2].each do |n| %>
        |<%= (pitchers['era'][n] || { name: ' ', value: ' ' })&.values&.join('|') %>||<%= (pitchers['whip'][n] || { name: ' ', value: ' ' }).values.join('|') %>|
        <% end %>

        |Name|Wins||Name|SO|
        |-|-|-|-|-|
        <% [0,1,2].each do |n| %>
        |<%= (pitchers['w'][n] || { name: ' ', value: ' ' })&.values&.join('|') %>||<%= (pitchers['so'][n] || { name: ' ', value: ' ' }).values.join('|') %>|
        <% end %>
      BODY

      expect(sidebar.evaluated_body).to eq <<~MARKDOWN
        # AL West Standings

        |Standings|W|L|PCT|GB|
        |:-:|:-:|:-:|:-:|:-:|
        |[Dodgers](/r/Dodgers)|111|51|.685|-|
        |[Padres](/r/Padres)|89|73|.549|22|
        |[Giants](/r/SFGiants)|81|81|.500|30|
        |[D-backs](/r/azdiamondbacks)|74|88|.457|37|
        |[Rockies](/r/ColoradoRockies)|68|94|.420|43|

        [Updated](https://baseballbot.io) 7/4 at 2:28 AM PDT
        # July Schedule

        |S|M|T|W|T|F|S|
        |:-:|:-:|:-:|:-:|:-:|:-:|:-:|
        | | | | | |**^1 [](/r/Padres "Won 5-1")**|**^2 [](/r/Padres "Won 7-2")**|
        |**^3 [](/r/Padres "Lost 2-4")**|**^4 [](/r/ColoradoRockies "Won 5-3")**|**^5 [](/r/ColoradoRockies "Won 5-2")**|**^6 [](/r/ColoradoRockies "Won 2-1")**|**^7 [](/r/CHICubs "Won 5-3")**|**^8 [](/r/CHICubs "Won 4-3")**|**^9 [](/r/CHICubs "Won 4-2")**|
        |**^10 [](/r/CHICubs "Won 11-9")**|^11|*^12 [](/r/Cardinals "Lost 6-7")*|*^13 [](/r/Cardinals "Won 7-6")*|*^14 [](/r/Cardinals "Won 4-0")*|*^15 [](/r/AngelsBaseball "Won 9-1")*|*^16 [](/r/AngelsBaseball "Won 7-1")*|
        |^17|^18|^19|^20|**^21 [](/r/SFGiants "Won 9-6")**|**^22 [](/r/SFGiants "Won 5-1")**|**^23 [](/r/SFGiants "Won 4-2")**|
        |**^24 [](/r/SFGiants "Won 7-4")**|**^25 [](/r/Nationals "Lost 1-4")**|**^26 [](/r/Nationals "Lost 3-8")**|**^27 [](/r/Nationals "Won 7-1")**|*^28 [](/r/ColoradoRockies "Won 13-0")*|*^29 [](/r/ColoradoRockies "Won 5-4")*|*^30 [](/r/ColoradoRockies "Lost 3-5")*|
        |*^31 [](/r/ColoradoRockies "Won 7-3")*| | | | | | |
        # Team Leaders

        ## Hitting

        |Name|OPS||Name|AVG|
        |-|-|-|-|-|
        |F Freeman|.937||F Freeman|.322|
        |M Betts|.865||T Turner|.306|
        |T Turner|.848||G Lux|.298|

        |Name|HR||Name|RBI|
        |-|-|-|-|-|
        |M Betts|22||T Turner|69|
        |T Turner|15||F Freeman|62|
        |F Freeman|15||J Turner|53|

        ## Pitching

        |Name|ERA||Name|WHIP|
        |-|-|-|-|-|
        |T Gonsolin|2.260||T Gonsolin|.880|
        |J Urías|2.720||J Urías|1.000|
        |T Anderson|2.790||T Anderson|1.020|

        |Name|Wins||Name|SO|
        |-|-|-|-|-|
        |T Gonsolin|11||J Urías|99|
        |T Anderson|10||T Gonsolin|90|
        |J Urías|9||T Anderson|87|
      MARKDOWN
    end
  end
end

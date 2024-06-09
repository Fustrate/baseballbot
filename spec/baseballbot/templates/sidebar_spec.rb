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

    it 'generates division standings' do
      sidebar = described_class.new(subreddit: default_subreddit, body: <<~MUSTACHE.strip)
        ### NL West Standings

        |Team|W|L|PCT|GB|
        |-|-|-|-|-|
        {{#division_standings}}
        |[{{name}}](/r/{{subreddit}})|{{wins}}|{{losses}}|{{percent}}|{{games_back}}|
        {{/division_standings}}
      MUSTACHE

      expect(sidebar.evaluated_body).to eq <<~MARKDOWN
        ### NL West Standings

        |Team|W|L|PCT|GB|
        |-|-|-|-|-|
        |[Dodgers](/r/Dodgers)|111|51|.685|-|
        |[Padres](/r/Padres)|89|73|.549|22|
        |[Giants](/r/SFGiants)|81|81|.500|30|
        |[D-backs](/r/azdiamondbacks)|74|88|.457|37|
        |[Rockies](/r/ColoradoRockies)|68|94|.420|43|
      MARKDOWN
    end

    it 'highlights the current team in the division standings' do
      sidebar = described_class.new(subreddit: default_subreddit, body: <<~MUSTACHE)
        |Team|W|L|GB|
        |-|:-:|:-:|:-:|
        {{#division_standings}}
        {{#current}}
        |[](/r/{{subreddit}}) DODGERS|**{{wins}}**|**{{losses}}**|**{{games_back}}**|
        {{/current}}
        {{^current}}
        |[](/r/{{subreddit}}) {{name}}|{{wins}}|{{losses}}|{{games_back}}|
        {{/current}}
        {{/division_standings}}
      MUSTACHE

      expect(sidebar.evaluated_body.strip).to eq <<~MARKDOWN.strip
        |Team|W|L|GB|
        |-|:-:|:-:|:-:|
        |[](/r/Dodgers) DODGERS|**111**|**51**|**-**|
        |[](/r/Padres) Padres|89|73|22|
        |[](/r/SFGiants) Giants|81|81|30|
        |[](/r/azdiamondbacks) D-backs|74|88|37|
        |[](/r/ColoradoRockies) Rockies|68|94|43|
      MARKDOWN
    end

    it 'generates the current month\'s games' do
      sidebar = described_class.new(subreddit: default_subreddit, body: <<~BODY.strip)
        |Date|Opponent|Score|
        |-|-|-|
        {{#month_games}}
        |{{date.short_day_of_week}}, {{date.month}}/{{date.day}}|{{where}} [](/{{opponent.code}}) {{opponent.name}}|{{status}}|
        {{/month_games}}
      BODY

      expect(sidebar.evaluated_body.strip).to eq <<~MARKDOWN.strip
        |Date|Opponent|Score|
        |-|-|-|
        |Fri, 7/1|vs [](/SD) Padres|Won 5-1|
        |Sat, 7/2|vs [](/SD) Padres|Won 7-2|
        |Sun, 7/3|vs [](/SD) Padres|Lost 2-4|
        |Mon, 7/4|vs [](/COL) Rockies|Won 5-3|
        |Tue, 7/5|vs [](/COL) Rockies|Won 5-2|
        |Wed, 7/6|vs [](/COL) Rockies|Won 2-1|
        |Thu, 7/7|vs [](/CHC) Cubs|Won 5-3|
        |Fri, 7/8|vs [](/CHC) Cubs|Won 4-3|
        |Sat, 7/9|vs [](/CHC) Cubs|Won 4-2|
        |Sun, 7/10|vs [](/CHC) Cubs|Won 11-9|
        |Tue, 7/12|@ [](/STL) Cardinals|Lost 6-7|
        |Wed, 7/13|@ [](/STL) Cardinals|Won 7-6|
        |Thu, 7/14|@ [](/STL) Cardinals|Won 4-0|
        |Fri, 7/15|@ [](/LAA) Angels|Won 9-1|
        |Sat, 7/16|@ [](/LAA) Angels|Won 7-1|
        |Thu, 7/21|vs [](/SF) Giants|Won 9-6|
        |Fri, 7/22|vs [](/SF) Giants|Won 5-1|
        |Sat, 7/23|vs [](/SF) Giants|Won 4-2|
        |Sun, 7/24|vs [](/SF) Giants|Won 7-4|
        |Mon, 7/25|vs [](/WSH) Nationals|Lost 1-4|
        |Tue, 7/26|vs [](/WSH) Nationals|Lost 3-8|
        |Wed, 7/27|vs [](/WSH) Nationals|Won 7-1|
        |Thu, 7/28|@ [](/COL) Rockies|Won 13-0|
        |Fri, 7/29|@ [](/COL) Rockies|Won 5-4|
        |Sat, 7/30|@ [](/COL) Rockies|Lost 3-5|
        |Sun, 7/31|@ [](/COL) Rockies|Won 7-3|
      MARKDOWN
    end

    it 'generates team stat leaders' do
      sidebar = described_class.new(subreddit: default_subreddit, body: <<~BODY.strip)
        <% hitters = hitter_stats(count: 3) %>
        <% pitchers = pitcher_stats(count: 3) %>

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

      expect(sidebar.evaluated_body.strip).to eq <<~MARKDOWN.strip
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
        |F Freeman|15||F Freeman|62|
        |T Turner|15||J Turner|53|

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

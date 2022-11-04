# frozen_string_literal: true

RSpec.describe Baseballbot::Templates::GameThread do
  before do
    stub_requests! with_response: true
  end

  describe '#to_s' do
    it 'generates a dull template' do
      template = game_thread_template(:preview, body: <<~BODY.strip)
        Hello World
      BODY

      expect(template.evaluated_body).to eq 'Hello World'
    end

    it 'adds a few blocks' do
      template = game_thread_template(:preview, body: <<~BODY.strip)
        {{thumbnail}}

        [{{home_team.name}} ({{home_record}})](/r/{{home_subreddit}}#home)|[{{away_team.name}} ({{away_record}})](/r/{{away_subreddit}}#away)
        :-:|:-:

        {{first_pitch}}

        {{probables_and_media}}

        MLB|Fangraphs|Reddit Stream|Discord
        :-:|:-:|:-:|:-:|:-:
        [Gameday]({{gameday_link}})|[Game Graph]({{& game_graph_link}})|[Live Comments](https://reddit-stream.com/comments/auto)|[/r/baseball Discord]({{discord_link}})

        [](/baseballbot)
        {{line_score_section}}

        {{box_score_section}}

        {{timestamp}}
        [](/baseballbot)

        Remember to **sort by new** to keep up!
      BODY

      expect(template.evaluated_body).to eq <<~MARKDOWN.strip
        [](http://mlb.mlb.com/images/2017_ipad/684/wasla_684.jpg)

        [Dodgers (111-51)](/r/Dodgers#home)|[Nationals (55-107)](/r/Nationals#away)
        :-:|:-:

        **First Pitch**: 7:10 PM at Dodger Stadium

        |Team|Starter|TV|Radio|
        |-|-|-|-|
        |[Nationals](/r/Nationals)|[Josiah Gray](https://www.mlb.com/player/680686) (7-6, 4.40 ERA)|MSN2|WJFK|
        |[Dodgers](/r/Dodgers)|[Mitch White](https://www.mlb.com/player/669952) (1-2, 3.78 ERA)|SNLA|570, KTNQ (ES)|

        MLB|Fangraphs|Reddit Stream|Discord
        :-:|:-:|:-:|:-:|:-:
        [Gameday](https://www.mlb.com/gameday/662573)|[Game Graph](http://www.fangraphs.com/livewins.aspx?date=2022-07-26&team=Dodgers&dh=0&season=2022)|[Live Comments](https://reddit-stream.com/comments/auto)|[/r/baseball Discord](https://discord.gg/rbaseball)

        [](/baseballbot)
        ### Line Score - Scheduled

        | |1|2|3|4|5|6|7|8|9|R|H|E|LOB|
        |-|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
        |WSH| | | | | | | | | |**0**|**0**|**0**|**-**|
        |LAD| | | | | | | | | |**0**|**0**|**0**|**-**|

        ### Box Score

        *Posted at 2:28 AM.* *Updates start at game time.*
        [](/baseballbot)

        Remember to **sort by new** to keep up!
      MARKDOWN
    end
  end
end

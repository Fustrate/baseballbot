# frozen_string_literal: true

RSpec.describe Baseballbot::Templates::GameThreads::Components::ScoringPlays do
  before do
    stub_requests! with_response: true
  end

  describe '#scoring_plays_section' do
    it 'generates a Scoring Plays section' do
      template = game_thread_template(:in_progress)

      expect(template.scoring_plays_section.to_s).to eq <<~MARKDOWN.strip
        ### Scoring Plays

        |Inning|Event|Score|
        |:-:|-|:-:|
        |T2|Alec Bohm singles on a line drive to right fielder Juan Soto.   Bryce Harper scores.    Nick Castellanos to 3rd.    Alec Bohm to 2nd.  Alec Bohm advances to 2nd, on a throwing error by right fielder Juan Soto.|0-**1**|
        |T2|Matt Vierling doubles (1) on a fly ball to right fielder Juan Soto.   Nick Castellanos scores.    Alec Bohm to 3rd.|0-**2**|
        |T2|Edmundo Sosa singles on a fly ball to left fielder Jurickson Profar.   Alec Bohm scores.    Matt Vierling to 3rd.|0-**3**|
        |T2|Kyle Schwarber grounds out to first baseman Brandon Drury.   Matt Vierling scores.    Edmundo Sosa to 2nd.|0-**4**|
        |B2|Brandon Drury homers (1) on a line drive to left field.|**1**-4|
        |B2|Josh Bell homers (2) on a fly ball to right field.|**2**-4|
        |B5|Austin Nola singles on a line drive to right fielder Nick Castellanos.   Ha-Seong Kim scores.|**3**-4|
        |B5|Juan Soto doubles (2) on a sharp line drive to right fielder Nick Castellanos.   Austin Nola scores.    Jurickson Profar to 3rd.|**4**-4|
        |B5|Brandon Drury singles on a line drive to center fielder Matt Vierling.   Jurickson Profar scores.    Juan Soto scores.    Jake Cronenworth to 3rd.|**6**-4|
        |B5|Josh Bell singles on a ground ball to right fielder Nick Castellanos.   Jake Cronenworth scores.    Brandon Drury to 3rd.|**7**-4|
      MARKDOWN
    end
  end
end

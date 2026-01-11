# frozen_string_literal: true

RSpec.describe Baseballbot::Templates::Blocks::DivisionStandings do
  include BotHelpers
  include WebmockHelpers

  let(:bot) { Baseballbot.new(user_agent: 'Baseballbot Tests') }
  let(:subreddit) do
    Baseballbot::Subreddit.new(
      { 'name' => 'dodgers', 'team_code' => 'LAD', 'team_id' => 119, 'options' => '{}' },
      bot:,
      bot_account: Baseballbot::Bot.new(bot:, name: 'RSpecTestBot', access: '')
    )
  end
  let(:template) { instance_double(Baseballbot::Template, month_name: 'July', year: 2022) }

  before do
    stub_requests!(with_response: true)
    allow(subreddit).to receive(:today).and_return(Date.new(2022, 7, 15))
  end

  describe '#render' do
    it 'renders standings table with default title' do
      standings = described_class.new(subreddit, template:)
      result = standings.render

      expect(result).to start_with('## 2022 Division Standings')
    end

    it 'renders standings table with custom title' do
      standings = described_class.new(subreddit, template:, 'title' => '## Custom Title')
      result = standings.render

      expect(result).to start_with('## Custom Title')
    end

    it 'interpolates variables in the title' do
      standings = described_class.new(subreddit, template:, 'title' => '## {{year}} NL West Standings')
      result = standings.render

      expect(result).to start_with('## 2022 NL West Standings')
    end

    it 'renders standings table with default columns' do
      standings = described_class.new(subreddit, template:)
      result = standings.render

      expect(result).to include('Team|W|L|PCT|GB|L10')
      expect(result).to include('**[](/r/Dodgers)**|111|51|.685|-|6-4')
      expect(result).to include('[](/r/Padres)|89|73|.549|22|5-5')
    end

    it 'renders standings table with custom columns' do
      standings = described_class.new(
        subreddit,
        template:,
        'columns' => %w[team_logo wins losses percent]
      )
      result = standings.render

      expect(result).to include('Team|W|L|PCT')
      expect(result).not_to include('GB')
      expect(result).not_to include('L10')
    end

    it 'supports additional columns' do
      standings = described_class.new(
        subreddit,
        template:,
        'columns' => %w[team_logo wins losses percent streak home_record road_record]
      )
      result = standings.render

      expect(result).to include('Team|W|L|PCT|STRK|Home|Road')
    end

    it 'bolds the current team' do
      standings = described_class.new(subreddit, template:)
      result = standings.render

      expect(result).to include('**[](/r/Dodgers)**')
      expect(result).not_to include('**[](/r/Padres)**')
    end

    it 'stores a reference to the template' do
      specific_template = instance_double(Baseballbot::Template)
      standings = described_class.new(subreddit, template: specific_template)

      expect(standings.template).to eq(specific_template)
    end
  end

  describe '#table_headers' do
    it 'returns proper headers for default columns' do
      standings = described_class.new(subreddit, template:)
      headers = standings.send(:table_headers)

      expect(headers).to eq(
        [
          ['Team', :left],
          ['W', :center],
          ['L', :center],
          ['PCT', :center],
          ['GB', :center],
          ['L10', :center]
        ]
      )
    end

    it 'returns proper headers for custom columns' do
      standings = described_class.new(
        subreddit,
        template:,
        'columns' => %w[team_logo streak run_diff]
      )
      headers = standings.send(:table_headers)

      expect(headers).to eq(
        [
          ['Team', :left],
          ['STRK', :center],
          ['RD', :center]
        ]
      )
    end
  end

  describe '#division_standings' do
    it 'loads the division standings data' do
      standings = described_class.new(subreddit, template:)
      division_standings = standings.send(:division_standings)

      expect(division_standings).to be_a(Array)
      expect(division_standings).to all(be_a(Baseballbot::Templates::Components::StandingsTeam))
      expect(division_standings.count).to eq(5)
    end
  end
end

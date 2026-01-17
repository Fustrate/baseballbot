# frozen_string_literal: true

RSpec.describe Baseballbot::Templates::Blocks::Calendar do
  include BotHelpers
  include WebmockHelpers

  let(:bot) { Baseballbot.new(user_agent: 'Baseballbot Tests') }
  let(:subreddit) do
    Baseballbot::Subreddit.new(
      { name: 'dodgers', team_code: 'LAD', team_id: 119, options: {} },
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
    it 'renders a calendar with default title' do
      calendar = described_class.new(subreddit, template:)
      result = calendar.render

      expect(result).to start_with('## July Schedule')
    end

    it 'renders a calendar with custom title' do
      calendar = described_class.new(subreddit, template:, 'title' => '## Custom Calendar Title')
      result = calendar.render

      expect(result).to start_with('## Custom Calendar Title')
    end

    it 'interpolates variables in the title' do
      calendar = described_class.new(subreddit, template:, 'title' => '## {{month_name}} Games')
      result = calendar.render

      expect(result).to start_with('## July Games')
    end

    it 'stores a reference to the template' do
      specific_template = instance_double(Baseballbot::Template)
      calendar = described_class.new(subreddit, template: specific_template)

      expect(calendar.template).to eq(specific_template)
    end
  end

  describe '#render_calendar' do
    let(:calendar) { described_class.new(subreddit, template:) }

    it 'generates calendar cells for the current month' do
      result = calendar.send(:render_calendar)

      expect(result).to be_a(String)
      expect(result).not_to be_empty
    end

    context 'with the buccos subreddit' do
      let(:buccos_subreddit) do
        Baseballbot::Subreddit.new(
          { name: 'buccos', team_code: 'PIT', team_id: 134, options: {} },
          bot:,
          bot_account: Baseballbot::Bot.new(bot:, name: 'RSpecTestBot', access: '')
        )
      end

      it 'uses buccos cell format' do
        allow(buccos_subreddit).to receive(:today).and_return(Date.new(2022, 7, 15))
        calendar = described_class.new(buccos_subreddit, template:)

        result = calendar.send(:render_calendar)

        expect(result).to be_a(String)
      end
    end
  end

  describe '#month_schedule' do
    let(:calendar) { described_class.new(subreddit, template:) }

    it 'returns a hash of dates with games' do
      schedule = calendar.send(:month_schedule)

      expect(schedule).to be_a(Hash)
      expect(schedule.keys).to all(match(/\d{4}-\d{2}-\d{2}/))
      expect(schedule.values).to all(have_key(:date))
      expect(schedule.values).to all(have_key(:games))
    end
  end

  describe '#month_start' do
    let(:calendar) { described_class.new(subreddit, template:) }

    it 'returns the first day of the current month' do
      expect(calendar.send(:month_start)).to eq(Date.new(2022, 7, 1))
    end
  end

  describe '#month_end' do
    let(:calendar) { described_class.new(subreddit, template:) }

    it 'returns the last day of the current month' do
      expect(calendar.send(:month_end)).to eq(Date.new(2022, 7, 31))
    end
  end

  describe '#cell' do
    let(:calendar) { described_class.new(subreddit, template:) }
    let(:opponent) { instance_double(MLBStatsAPI::Team, code: 'SF') }
    let(:game) do
      instance_double(
        Baseballbot::Templates::Blocks::Calendar::TeamCalendarGame,
        opponent:,
        home_team?: true,
        status: 'Won 5-3'
      )
    end

    it 'returns just the date for days with no games' do
      result = calendar.send(:cell, 15, [])
      expect(result).to eq('^15')
    end

    it 'returns bold format for home games' do
      allow(subreddit).to receive(:code_to_subreddit_name).with('SF').and_return('SFGiants')
      result = calendar.send(:cell, 15, [game])

      expect(result).to include('**^15')
      expect(result).to include('/r/SFGiants')
      expect(result).to include('**')
    end

    it 'returns italic format for away games' do
      allow(game).to receive(:home_team?).and_return(false)
      allow(subreddit).to receive(:code_to_subreddit_name).with('SF').and_return('SFGiants')
      result = calendar.send(:cell, 15, [game])

      expect(result).to include('*^15')
      expect(result).to include('/r/SFGiants')
      expect(result).not_to include('**')
    end
  end

  describe '#buccos_cell' do
    let(:buccos_subreddit) do
      Baseballbot::Subreddit.new(
        { name: 'buccos', team_code: 'PIT', team_id: 134, options: {} },
        bot:,
        bot_account: Baseballbot::Bot.new(bot:, name: 'RSpecTestBot', access: '')
      )
    end
    let(:calendar) { described_class.new(buccos_subreddit, template:) }
    let(:opponent) { instance_double(MLBStatsAPI::Team, code: 'MIL') }
    let(:game_date) { Time.new(2022, 7, 15, 19, 10) }
    let(:game) do
      instance_double(
        Baseballbot::Templates::Blocks::Calendar::TeamCalendarGame,
        opponent:,
        home_team?: true,
        status: 'Preview',
        date: game_date
      )
    end

    it 'returns off day format for days with no games' do
      result = calendar.send(:buccos_cell, 5, [])
      expect(result).to eq('05 [](/offday)[](/offdaybar)')
    end

    it 'returns formatted game time and opponent for scheduled games' do
      allow(buccos_subreddit).to receive(:code_to_subreddit_name).with('MIL').and_return('Brewers')
      result = calendar.send(:buccos_cell, 15, [game])

      expect(result).to match(/15 \[7:10\]/)
      expect(result).to include('/r/Brewers')
      expect(result).to include('Home')
    end

    it 'uses Away flag for away games' do
      allow(game).to receive(:home_team?).and_return(false)
      allow(buccos_subreddit).to receive(:code_to_subreddit_name).with('MIL').and_return('Brewers')
      result = calendar.send(:buccos_cell, 15, [game])

      expect(result).to include('Away')
      expect(result).not_to include('Home')
    end
  end

  describe Baseballbot::Templates::Blocks::Calendar::SubredditSchedule do
    let(:schedule) { described_class.new(subreddit:, team_id: 119) }
    let(:start_date) { Date.new(2022, 7, 1) }
    let(:end_date) { Date.new(2022, 7, 31) }

    describe '#generate' do
      it 'generates a schedule hash for the date range' do
        result = schedule.generate(start_date, end_date)

        expect(result).to be_a(Hash)
        expect(result['2022-07-01']).to have_key(:date)
        expect(result['2022-07-01']).to have_key(:games)
        expect(result['2022-07-31']).to have_key(:date)
        expect(result['2022-07-31']).to have_key(:games)
      end
    end

    describe '#build_date_hash' do
      it 'creates a hash entry for each date in the range' do
        result = schedule.send(:build_date_hash, start_date, end_date)

        expect(result.keys.size).to eq(31)
        expect(result.keys.first).to eq('2022-07-01')
        expect(result.keys.last).to eq('2022-07-31')
      end
    end
  end

  describe Baseballbot::Templates::Blocks::Calendar::TeamCalendarGame do
    let(:api) { bot.api }
    let(:data) do
      {
        'gamePk' => 12_345,
        'gameDate' => '2022-07-15T19:10:00Z',
        'status' => { 'statusCode' => 'F' },
        'teams' => {
          'away' => { 'team' => { 'id' => 137 }, 'score' => 5 },
          'home' => { 'team' => { 'id' => 119 }, 'score' => 3 }
        },
        'broadcasts' => [
          { 'callSign' => 'ESPN', 'type' => 'TV', 'language' => 'en', 'homeAway' => 'home' }
        ]
      }
    end
    let(:game_date) { Time.new(2022, 7, 15, 12, 10) }
    let(:game) { described_class.new(api:, data:, team_id: 119, date: game_date) }

    describe '#home_team?' do
      it 'returns true when team_id matches home team' do
        expect(game.home_team?).to be true
      end

      it 'returns false when team_id matches away team' do
        game = described_class.new(api:, data:, team_id: 137, date: game_date)
        expect(game.home_team?).to be false
      end
    end

    describe '#final?' do
      it 'returns true for final game status codes' do
        %w[F C D FT FR].each do |code|
          data['status']['statusCode'] = code
          game = described_class.new(api:, data:, team_id: 119, date: game_date)
          expect(game.final?).to be true
        end
      end

      it 'returns false for non-final status codes' do
        data['status']['statusCode'] = 'P'
        game = described_class.new(api:, data:, team_id: 119, date: game_date)
        expect(game.final?).to be false
      end
    end

    describe '#outcome' do
      it 'returns Won when team score is higher' do
        data['teams']['home']['score'] = 5
        data['teams']['away']['score'] = 3
        game = described_class.new(api:, data:, team_id: 119, date: game_date)
        expect(game.outcome).to eq('Won')
      end

      it 'returns Lost when opponent score is higher' do
        data['teams']['home']['score'] = 3
        data['teams']['away']['score'] = 5
        game = described_class.new(api:, data:, team_id: 119, date: game_date)
        expect(game.outcome).to eq('Lost')
      end

      it 'returns Tied when scores are equal' do
        data['teams']['home']['score'] = 3
        data['teams']['away']['score'] = 3
        game = described_class.new(api:, data:, team_id: 119, date: game_date)
        expect(game.outcome).to eq('Tied')
      end

      it 'returns nil for non-final games' do
        data['status']['statusCode'] = 'P'
        game = described_class.new(api:, data:, team_id: 119, date: game_date)
        expect(game.outcome).to be_nil
      end
    end

    describe '#status' do
      it 'returns final score for completed games' do
        expect(game.status).to eq('Lost 3-5')
      end

      it 'returns Delayed for delayed games' do
        data['status']['statusCode'] = 'DR'
        game = described_class.new(api:, data:, team_id: 119, date: game_date)
        expect(game.status).to eq('Delayed')
      end

      it 'returns game time and TV stations for preview games' do
        data['status']['statusCode'] = 'P'
        game = described_class.new(api:, data:, team_id: 119, date: game_date)
        expect(game.status).to include('12:10')
        expect(game.status).to include('ESPN')
      end
    end

    describe '#tv_stations' do
      it 'returns TV station call signs for home team English broadcasts' do
        expect(game.tv_stations).to eq('ESPN')
      end

      it 'filters out non-TV broadcasts' do
        data['broadcasts'] << { 'callSign' => 'RADIO', 'type' => 'RADIO', 'language' => 'en', 'homeAway' => 'home' }
        game = described_class.new(api:, data:, team_id: 119, date: game_date)
        expect(game.tv_stations).to eq('ESPN')
      end

      it 'returns empty string when no broadcasts' do
        data['broadcasts'] = nil
        game = described_class.new(api:, data:, team_id: 119, date: game_date)
        expect(game.tv_stations).to eq('')
      end
    end

    describe '#wlt' do
      it 'returns W for won games' do
        data['teams']['home']['score'] = 5
        data['teams']['away']['score'] = 3
        game = described_class.new(api:, data:, team_id: 119, date: game_date)
        expect(game.wlt).to eq('W')
      end

      it 'returns L for lost games' do
        expect(game.wlt).to eq('L')
      end

      it 'returns T for tied games' do
        data['teams']['home']['score'] = 3
        data['teams']['away']['score'] = 3
        game = described_class.new(api:, data:, team_id: 119, date: game_date)
        expect(game.wlt).to eq('T')
      end

      it 'returns empty string for non-final games' do
        data['status']['statusCode'] = 'P'
        game = described_class.new(api:, data:, team_id: 119, date: game_date)
        expect(game.wlt).to eq('')
      end
    end

    describe '#visible?' do
      it 'returns true for current team regular games' do
        data['ifNecessary'] = 'N'
        data['rescheduleDate'] = nil
        game = described_class.new(api:, data:, team_id: 119, date: game_date)
        expect(game.visible?).to be true
      end

      it 'returns false for if-necessary games' do
        data['ifNecessary'] = 'Y'
        game = described_class.new(api:, data:, team_id: 119, date: game_date)
        expect(game.visible?).to be false
      end

      it 'returns false for rescheduled games' do
        data['rescheduleDate'] = '2022-08-01'
        game = described_class.new(api:, data:, team_id: 119, date: game_date)
        expect(game.visible?).to be false
      end

      it 'returns false when neither team matches team_id' do
        game = described_class.new(api:, data:, team_id: 999, date: game_date)
        expect(game.visible?).to be false
      end
    end
  end
end

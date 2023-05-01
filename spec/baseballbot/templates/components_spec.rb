# frozen_string_literal: true

class TemplateComponents
  def initialize(subreddit)
    @subreddit = subreddit
  end

  include Baseballbot::Templates::Components
end

# This is basically just testing that the methods are forwarding properly
RSpec.describe Baseballbot::Templates::Components do
  let(:bot) { Baseballbot.new(user_agent: 'Baseballbot Tests') }
  let(:subreddit) do
    Baseballbot::Subreddit.new(
      { 'name' => 'dodgers', 'team_code' => 'LAD', 'team_id' => 119, 'options' => '{}' },
      bot:,
      account: (Baseballbot::Account.new bot:, name: 'RSpecTestBot', access: '')
    )
  end

  describe '#todays_games' do
    it 'creates a Today\'s Games table' do
      expect(Baseballbot::Templates::Components::TodaysGames)
        .to receive(:new).with(subreddit, date: nil, links: :code)

      TemplateComponents.new(subreddit).todays_games
    end

    it 'creates a Today\'s Games table for a specific date' do
      date = subreddit.today - 3

      expect(Baseballbot::Templates::Components::TodaysGames)
        .to receive(:new).with(subreddit, date:, links: :code)

      TemplateComponents.new(subreddit).todays_games(date)
    end
  end

  describe 'Schedule methods' do
    let(:schedule) { instance_double(Baseballbot::Templates::Components::Schedule) }

    describe '#month_games' do
      it 'returns a list of games for an entire month' do
        expect(schedule).to receive(:month_games)

        allow(Baseballbot::Templates::Components::Schedule)
          .to receive(:new).with(subreddit).and_return(schedule)

        TemplateComponents.new(subreddit).month_games
      end
    end

    describe '#previous_games' do
      it 'returns a list of the X most recently completed games' do
        expect(schedule).to receive(:previous_games).with(10)

        allow(Baseballbot::Templates::Components::Schedule)
          .to receive(:new).with(subreddit).and_return(schedule)

        TemplateComponents.new(subreddit).previous_games 10
      end
    end

    describe '#upcoming_games' do
      it 'returns a list of the next X upcoming games' do
        expect(schedule).to receive(:upcoming_games).with(10)

        allow(Baseballbot::Templates::Components::Schedule)
          .to receive(:new).with(subreddit).and_return(schedule)

        TemplateComponents.new(subreddit).upcoming_games 10
      end
    end

    describe '#next_game_str' do
      it 'outputs a description of the next game' do
        expect(schedule).to receive(:next_game_str)

        allow(Baseballbot::Templates::Components::Schedule)
          .to receive(:new).with(subreddit).and_return(schedule)

        TemplateComponents.new(subreddit).next_game_str
      end
    end

    describe '#last_game_str' do
      it 'outputs a description of the previous game' do
        expect(schedule).to receive(:last_game_str)

        allow(Baseballbot::Templates::Components::Schedule)
          .to receive(:new).with(subreddit).and_return(schedule)

        TemplateComponents.new(subreddit).last_game_str
      end
    end
  end

  describe '#division_standings' do
    it 'returns an array of this team\'s division\'s standings' do
      expect(Baseballbot::Templates::Components::DivisionStandings).to receive(:new).with(subreddit)

      TemplateComponents.new(subreddit).division_standings
    end
  end

  describe '#league_standings' do
    it 'outputs league standings for /r/baseball' do
      expect(Baseballbot::Templates::Components::LeagueStandings).to receive(:new).with(subreddit)

      TemplateComponents.new(subreddit).league_standings
    end
  end
end

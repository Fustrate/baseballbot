# frozen_string_literal: true

class SidebarComponents
  def initialize(subreddit)
    @subreddit = subreddit
  end

  include Baseballbot::Templates::Sidebars::Components
end

# This is basically just testing that the methods are forwarding properly
RSpec.describe Baseballbot::Templates::Sidebars::Components do
  let(:bot) { Baseballbot.new(user_agent: 'Baseballbot Tests') }
  let(:subreddit) do
    Baseballbot::Subreddit.new(
      { 'name' => 'dodgers', 'team_code' => 'LAD', 'team_id' => 119, 'options' => '{}' },
      bot:,
      account: (Baseballbot::Account.new bot:, name: 'RSpecTestBot', access: '')
    )
  end

  describe '#postseason_series_section' do
    it 'creates a postseason section' do
      expect(Baseballbot::Templates::Sidebars::Components::Postseason).to receive(:new).with(subreddit)

      SidebarComponents.new(subreddit).postseason_series_section
    end
  end

  describe '#todays_games' do
    it 'creates a Today\'s Games table' do
      expect(Baseballbot::Templates::Sidebars::Components::TodaysGames)
        .to receive(:new).with(subreddit, date: nil, links: :code)

      SidebarComponents.new(subreddit).todays_games
    end

    it 'creates a Today\'s Games table for a specific date' do
      date = subreddit.today - 3

      expect(Baseballbot::Templates::Sidebars::Components::TodaysGames)
        .to receive(:new).with(subreddit, date:, links: :code)

      SidebarComponents.new(subreddit).todays_games(date)
    end
  end

  describe 'Leaders methods' do
    let(:leaders) { instance_double(Baseballbot::Templates::Sidebars::Components::Leaders) }

    describe '#hitter_stats' do
      it 'creates an array of hitting leaders' do
        expect(leaders).to receive(:hitter_stats)

        allow(Baseballbot::Templates::Sidebars::Components::Leaders).to receive(:new).with(subreddit) { leaders }

        SidebarComponents.new(subreddit).hitter_stats
      end
    end

    describe '#hitter_stats_table' do
      it 'creates a hitting leaders table' do
        expect(leaders).to receive(:hitter_stats_table)

        allow(Baseballbot::Templates::Sidebars::Components::Leaders).to receive(:new).with(subreddit) { leaders }

        SidebarComponents.new(subreddit).hitter_stats_table
      end
    end

    describe '#pitcher_stats' do
      it 'creates an array of pitching leaders' do
        expect(leaders).to receive(:pitcher_stats)

        allow(Baseballbot::Templates::Sidebars::Components::Leaders).to receive(:new).with(subreddit) { leaders }

        SidebarComponents.new(subreddit).pitcher_stats
      end
    end

    describe '#pitcher_stats_table' do
      it 'creates a pitching leaders table' do
        expect(leaders).to receive(:pitcher_stats_table)

        allow(Baseballbot::Templates::Sidebars::Components::Leaders).to receive(:new).with(subreddit) { leaders }

        SidebarComponents.new(subreddit).pitcher_stats_table
      end
    end
  end

  describe '#calendar' do
    it 'creates a calendar' do
      expect(Baseballbot::Templates::Sidebars::Components::Calendar).to receive(:new).with(subreddit)

      SidebarComponents.new(subreddit).calendar
    end
  end

  describe 'Schedule methods' do
    let(:schedule) { instance_double(Baseballbot::Templates::Sidebars::Components::Schedule) }

    describe '#month_games' do
      it 'returns a list of games for an entire month' do
        expect(schedule).to receive(:month_games)

        allow(Baseballbot::Templates::Sidebars::Components::Schedule)
          .to receive(:new).with(subreddit).and_return(schedule)

        SidebarComponents.new(subreddit).month_games
      end
    end

    describe '#previous_games' do
      it 'returns a list of the X most recently completed games' do
        expect(schedule).to receive(:previous_games).with(10)

        allow(Baseballbot::Templates::Sidebars::Components::Schedule)
          .to receive(:new).with(subreddit).and_return(schedule)

        SidebarComponents.new(subreddit).previous_games 10
      end
    end

    describe '#upcoming_games' do
      it 'returns a list of the next X upcoming games' do
        expect(schedule).to receive(:upcoming_games).with(10)

        allow(Baseballbot::Templates::Sidebars::Components::Schedule)
          .to receive(:new).with(subreddit).and_return(schedule)

        SidebarComponents.new(subreddit).upcoming_games 10
      end
    end

    describe '#next_game_str' do
      it 'outputs a description of the next game' do
        expect(schedule).to receive(:next_game_str)

        allow(Baseballbot::Templates::Sidebars::Components::Schedule)
          .to receive(:new).with(subreddit).and_return(schedule)

        SidebarComponents.new(subreddit).next_game_str
      end
    end

    describe '#last_game_str' do
      it 'outputs a description of the previous game' do
        expect(schedule).to receive(:last_game_str)

        allow(Baseballbot::Templates::Sidebars::Components::Schedule)
          .to receive(:new).with(subreddit).and_return(schedule)

        SidebarComponents.new(subreddit).last_game_str
      end
    end
  end

  describe '#division_standings' do
    it 'returns an array of this team\'s division\'s standings' do
      expect(Baseballbot::Templates::Sidebars::Components::DivisionStandings).to receive(:new).with(subreddit)

      SidebarComponents.new(subreddit).division_standings
    end
  end

  describe '#league_standings' do
    it 'outputs league standings for /r/baseball' do
      expect(Baseballbot::Templates::Sidebars::Components::LeagueStandings).to receive(:new).with(subreddit)

      SidebarComponents.new(subreddit).league_standings
    end
  end

  describe '#updated_with_link' do
    it 'outputs a timestamp' do
      expect(SidebarComponents.new(subreddit).updated_with_link)
        .to eq '[Updated](https://baseballbot.io) 7/4 at 2:28 AM PDT'
    end
  end
end

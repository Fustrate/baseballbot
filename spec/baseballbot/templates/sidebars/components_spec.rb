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
      bot_account: Baseballbot::Bot.new(bot:, name: 'RSpecTestBot', access: '')
    )
  end

  describe '#postseason_series_section' do
    it 'creates a postseason section' do
      expect(Baseballbot::Templates::Sidebars::Components::Postseason).to receive(:new).with(subreddit)

      SidebarComponents.new(subreddit).postseason_series_section
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

  describe '#updated_with_link' do
    it 'outputs a timestamp' do
      expect(SidebarComponents.new(subreddit).updated_with_link)
        .to eq '[Updated](https://baseballbot.io) 7/4 at 2:28 AM PDT'
    end
  end
end

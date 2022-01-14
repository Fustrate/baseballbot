# frozen_string_literal: true

class Subject
  include Baseballbot::Template::Sidebar::Leaders

  def initialize(subreddit:)
    @subreddit = subreddit
  end
end

class FakeBot < Baseballbot
  def initialize
    super user_agent: 'Baseballbot Fake Bot for Tests'
  end
end

RSpec.describe Baseballbot::Template::Sidebar::Leaders do
  describe '#hitter_stats' do
    it 'loads stuff' do
      bot = Baseballbot.new(user_agent: 'Baseballbot Tests')
      account = Baseballbot::Account.new bot:, name: 'RSpecTestBot', access: ''
      subreddit = Baseballbot::Subreddit.new({ name: 'dodgers', team_code: 'LAD', team_id: 119 }, bot:, account:)
      thing = Subject.new(subreddit:)

      thing.hitter_stats
    end
  end
end

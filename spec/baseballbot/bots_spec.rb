# frozen_string_literal: true

RSpec.describe Baseballbot::Bots do
  include BotHelpers

  let(:bot) { default_bot }
  let(:client) { instance_double(Redd::APIClient) }
  let(:access_token) { 'test_access_token' }
  let(:refresh_token) { 'test_refresh_token' }
  let(:new_access_token) { 'new_access_token' }
  let(:scope) { %w[identity read submit] }
  let(:expires_at) { Time.parse('2022-07-04 09:28:41') + 3600 }
  let(:access) do
    instance_double(
      Redd::Models::Access,
      access_token:,
      refresh_token:,
      scope:,
      expires_in: 3600,
      expired?: false,
      to_h: {}
    )
  end

  before do
    allow(bot).to receive_messages(client:, sequel: DB)
    allow(client).to receive(:access=)
  end

  describe '#load_bots' do
    it 'loads all bots from the database' do
      bots = bot.send(:load_bots)

      expect(bots).to be_a(Hash)
      expect(bots.size).to eq(30)
      expect(bots.values).to all(be_a(Baseballbot::Bot))
    end

    it 'creates Bot objects with correct attributes' do
      bots = bot.send(:load_bots)
      test_bot = bots.values.find { |b| b.name == 'DodgerBot' }

      expect(test_bot.name).to eq('DodgerBot')
      expect(test_bot.access).to be_a(Redd::Models::Access)
    end
  end

  describe '#process_bot_row' do
    let(:row) do
      {
        'id' => 1,
        'name' => 'DodgerBot',
        'access_token' => access_token,
        'refresh_token' => refresh_token,
        'scope' => "{#{scope.join(',')}}",
        'expires_at' => expires_at.strftime('%Y-%m-%d %H:%M:%S')
      }
    end

    it 'creates a Bot object from a database row' do
      result = bot.send(:process_bot_row, row)

      expect(result).to be_a(Baseballbot::Bot)
      expect(result.name).to eq('DodgerBot')
    end
  end

  describe '#account_access' do
    let(:row) do
      {
        'access_token' => access_token,
        'refresh_token' => refresh_token,
        'scope' => "{#{scope.join(',')}}",
        'expires_at' => expires_at.strftime('%Y-%m-%d %H:%M:%S')
      }
    end

    it 'creates an Access object from a database row' do
      result = bot.send(:account_access, row)

      expect(result).to be_a(Redd::Models::Access)
      expect(result.access_token).to eq(access_token)
      expect(result.refresh_token).to eq(refresh_token)
      expect(result.scope).to eq(scope)
    end

    it 'handles scope as an array from Sequel' do
      result = bot.send(:account_access, row)

      expect(result.scope).to be_an(Array)
      expect(result.scope).to eq(scope)
    end

    it 'subtracts 60 seconds from expires_at to prevent credential issues' do
      result = bot.send(:account_access, row)

      # The account_access method passes expires_at - 60 to Redd,
      # but expires_in is calculated from the original expires_at value
      # So expires_in will be the full duration (3600 seconds)
      expect(result.expires_in).to be_within(5).of(3600)
    end
  end

  describe '#use_bot' do
    let(:bot_name) { 'TestBot1' }
    let(:test_bot) do
      instance_double(
        Baseballbot::Bot,
        name: bot_name,
        access:
      )
    end

    before do
      allow(bot).to receive(:bots).and_return({ 1 => test_bot })
      allow(bot).to receive(:refresh_access!)
    end

    it 'sets the current bot' do
      bot.use_bot(bot_name)

      expect(bot.current_bot).to eq(test_bot)
    end

    it 'sets the client access to the bot access' do
      expect(client).to receive(:access=).with(access)

      bot.use_bot(bot_name)
    end

    it 'does not change bot if already using the same bot' do
      bot.use_bot(bot_name)

      expect(client).not_to receive(:access=)

      bot.use_bot(bot_name)
    end

    context 'when access is expired' do
      before do
        allow(access).to receive(:expired?).and_return(true)
      end

      it 'refreshes the access token' do
        expect(bot).to receive(:refresh_access!)

        bot.use_bot(bot_name)
      end
    end

    context 'when access is not expired' do
      before do
        allow(access).to receive(:expired?).and_return(false)
      end

      it 'does not refresh the access token' do
        expect(bot).not_to receive(:refresh_access!)

        bot.use_bot(bot_name)
      end
    end
  end

  describe '#refresh_access!' do
    let(:new_expires_in) { 3600 }
    let(:new_access) do
      instance_double(
        Redd::Models::Access,
        access_token: new_access_token,
        refresh_token:,
        expires_in: new_expires_in,
        to_h: {}
      )
    end

    before do
      allow(client).to receive(:refresh)
      allow(client).to receive(:access).and_return(new_access)
      allow(bot).to receive(:update_token_expiration!)
    end

    it 'calls refresh on the client' do
      expect(client).to receive(:refresh)

      bot.refresh_access!
    end

    it 'updates the token expiration in the database' do
      new_expiration = Time.now + new_expires_in

      expect(bot).to receive(:update_token_expiration!) do |exp|
        expect(exp).to be_within(1).of(new_expiration)
      end

      bot.refresh_access!
    end

    it 'returns the client' do
      result = bot.refresh_access!

      expect(result).to eq(client)
    end

    context 'when refresh returns an error' do
      before do
        allow(new_access).to receive(:to_h).and_return({ error: 'invalid_grant' })
      end

      it 'does not update token expiration' do
        expect(bot).not_to receive(:update_token_expiration!)

        bot.refresh_access!
      end
    end
  end

  describe '#update_token_expiration!' do
    let(:new_expiration) { Time.now + 3600 }
    let(:bot_id) do
      DB[:bots].insert(
        name: 'UpdateBot',
        access_token:,
        refresh_token:,
        scope: Sequel.pg_array(scope),
        expires_at: expires_at.strftime('%F %T')
      )
    end

    before do
      bot_id # Ensure bot is created
      allow(client).to receive(:access).and_return(access)
    end

    it 'updates the access token in the database' do
      bot.send(:update_token_expiration!, new_expiration)

      updated_bot = DB[:bots].where(refresh_token:).first
      expect(updated_bot[:access_token]).to eq(access_token)
    end

    it 'updates the expires_at in the database' do
      bot.send(:update_token_expiration!, new_expiration)

      updated_bot = DB[:bots].where(refresh_token:).first
      # PostgreSQL's timestamp without time zone stores the time as-is,
      # but Sequel returns it interpreted in the local timezone.
      # Convert both to UTC for comparison.
      expect(updated_bot[:expires_at].utc.to_i).to be_within(1).of(new_expiration.utc.to_i)
    end
  end

  describe '#with_reddit_bot' do
    let(:bot_name) { 'TestBot1' }
    let(:test_bot) do
      instance_double(
        Baseballbot::Bot,
        name: bot_name,
        access:
      )
    end

    before do
      allow(bot).to receive(:bots).and_return({ 1 => test_bot })
      allow(bot).to receive(:use_bot)
      allow(bot).to receive(:refresh_access!)
      allow(Honeybadger).to receive(:context).and_yield
    end

    it 'calls use_bot with the bot name' do
      expect(bot).to receive(:use_bot).with(bot_name)

      bot.with_reddit_bot(bot_name) { 'test' }
    end

    it 'sets Honeybadger context with bot_name' do
      expect(Honeybadger).to receive(:context).with(bot_name:)

      bot.with_reddit_bot(bot_name) { 'test' }
    end

    it 'returns the result of the block' do
      result = bot.with_reddit_bot(bot_name) { 'return_value' }

      expect(result).to eq('return_value')
    end

    context 'when InvalidAccess error is raised' do
      let(:error_response) { instance_double(Redd::Client::Response, raw_body: 'Invalid access') }
      let(:invalid_access_error) { Redd::Errors::InvalidAccess.new(error_response) }

      it 'refreshes access and retries once' do
        call_count = 0

        allow(bot).to receive(:use_bot) do
          call_count += 1
          raise invalid_access_error if call_count == 1
        end

        expect(bot).to receive(:refresh_access!).once

        bot.with_reddit_bot(bot_name) { 'test' }

        expect(call_count).to eq(2)
      end

      it 'only retries once' do
        allow(bot).to receive(:use_bot).and_raise(invalid_access_error)
        allow(bot).to receive(:refresh_access!)

        expect do
          bot.with_reddit_bot(bot_name) { 'test' }
        end.to raise_error(Redd::Errors::InvalidAccess)
      end
    end
  end
end

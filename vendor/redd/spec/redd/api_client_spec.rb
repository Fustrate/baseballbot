# frozen_string_literal: true

RSpec.describe Redd::APIClient do
  let(:auth_strategy) { instance_double('Redd::AuthStrategies::AuthStrategy') }

  describe '#authenticate' do
    it 'calls #authenticate on the auth strategy with a given code' do
      allow(auth_strategy).to receive(:authenticate)

      described_class.new(auth_strategy).authenticate('some-code')

      expect(auth_strategy).to have_received(:authenticate).with('some-code')
    end

    it "sets the client's access to the result of the call" do
      access = instance_double('Redd::Models::Access')

      allow(auth_strategy).to receive(:authenticate).and_return(access)

      client = described_class.new(auth_strategy)
      client.authenticate

      expect(client.access).to eq(access)
    end
  end

  describe '#refresh' do
    it 'calls #refresh on the auth strategy' do
      client = described_class.new(auth_strategy)
      client.access = instance_double('Redd::Models::Access')

      allow(auth_strategy).to receive(:refresh).with(client.access)

      client.refresh

      expect(auth_strategy).to have_received(:refresh)
    end

    it "sets the client's access to the result of the call" do
      client = described_class.new(auth_strategy)
      access = instance_double('Redd::Models::Access')

      allow(auth_strategy).to receive(:refresh).and_return(access)

      client.refresh

      expect(client.access).to eq(access)
    end
  end

  describe '#revoke' do
    it 'calls #revoke on the auth strategy' do
      auth_strategy = instance_double('Redd::AuthStrategies::AuthStrategy')

      allow(auth_strategy).to receive(:revoke)

      described_class.new(auth_strategy).revoke

      expect(auth_strategy).to have_received(:revoke)
    end

    it "unsets the client's access" do
      auth_strategy = instance_double('Redd::AuthStrategies::AuthStrategy')
      allow(auth_strategy).to receive(:revoke)

      client = described_class.new(auth_strategy)
      client.revoke
      expect(client.access).to be_nil
    end
  end

  # TODO: expand into context blocks and implement
  it 'calls authenticate if auto_login is enabled and access is unset'
  it 'calls refresh if auto_refresh is enabled and access is expired'
  it 'retries a call if max_retries > 0 is enabled and a TimeoutError or a ServerError is raised'
end

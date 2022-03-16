# frozen_string_literal: true

RSpec.describe Redd do
  describe '.it' do
    it 'returns a Session' do
      strategy = instance_double('Redd::AuthStrategies::Script')
      allow(strategy).to receive(:authenticate)
      allow(Redd::AuthStrategies::Script).to receive(:new).and_return(strategy)

      session = described_class.it(client_id: 'AB', secret: 'CD', username: 'EF', password: 'GH')

      expect(session).to be_a(Redd::Models::Session)
    end

    context 'when only client_id, secret, username and password are provided' do
      let(:strategy) { instance_double('Redd::AuthStrategies::Script') }

      before do
        allow(strategy).to receive(:authenticate)

        allow(Redd::AuthStrategies::Script).to(
          receive(:new)
            .with(client_id: 'AB', secret: 'CD', username: 'EF', password: 'GH')
            .and_return(strategy)
        )
      end

      it 'creates an API client with AuthStrategies::Script' do
        described_class.it(client_id: 'AB', secret: 'CD', username: 'EF', password: 'GH')

        expect(strategy).to have_received(:authenticate)
      end
    end

    context 'when only client_id, redirect_uri and code are provided' do
      let(:strategy) { instance_double('Redd::AuthStrategies::Web') }

      before do
        allow(strategy).to receive(:authenticate)

        allow(Redd::AuthStrategies::Web).to(
          receive(:new)
            .with(client_id: 'AB', redirect_uri: 'CD')
            .and_return(strategy)
        )
      end

      it 'creates an API client with AuthStrategies::Web' do
        described_class.it(client_id: 'AB', redirect_uri: 'CD', code: 'EF')

        expect(strategy).to have_received(:authenticate).with('EF')
      end
    end

    context 'when only client_id, secret, redirect_uri and code are provided' do
      let(:strategy) { instance_double('Redd::AuthStrategies::Web') }

      before do
        allow(strategy).to receive(:authenticate)

        allow(Redd::AuthStrategies::Web).to(
          receive(:new)
            .with(client_id: 'AB', redirect_uri: 'CD', secret: 'XX')
            .and_return(strategy)
        )
      end

      it 'creates an API client with AuthStrategies::Web' do
        described_class.it(client_id: 'AB', secret: 'XX', redirect_uri: 'CD', code: 'EF')

        expect(strategy).to have_received(:authenticate).with('EF')
      end
    end

    context 'when only client_id and secret are provided' do
      let(:strategy) { instance_double('Redd::AuthStrategies::Userless') }

      before do
        allow(strategy).to receive(:authenticate)

        allow(Redd::AuthStrategies::Userless).to(
          receive(:new)
            .with(client_id: 'AB', secret: 'XX')
            .and_return(strategy)
        )
      end

      it 'creates an API client with AuthStrategies::Userless' do
        described_class.it(client_id: 'AB', secret: 'XX')

        expect(strategy).to have_received(:authenticate)
      end
    end
  end
end

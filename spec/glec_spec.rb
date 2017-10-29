require_relative '../glec'

include Glec

RSpec.describe Glec do
  describe '.get_events' do
    subject { proc { Glec.send(:get_events, parameter) } }

    context 'repository does not exist' do
      let(:parameter) { { owner: DEFAULT_OWNER, repo: 'not_exist_repo' } }
      code = '404'
      msg  = 'Not Found'
      before do
        allow_any_instance_of(Net::HTTPNotFound).to receive(:code).and_return(code)
        allow_any_instance_of(Net::HTTPNotFound).to receive(:msg).and_return(msg)
      end

      it { is_expected.to raise_error "#{code} : #{msg}" }
    end

    context 'repository exist' do
      let(:parameter) { { owner: DEFAULT_OWNER, repo: DEFAULT_REPO } }
      res = 'test_body'
      before do
        allow_any_instance_of(Net::HTTPOK).to receive(:body).and_return(res)
      end

      it { is_expected.not_to raise_error }
      it { expect(subject.call).to eq res }
    end
  end

  describe '.refine_by_user' do
    subject { Glec.send(:refine_by_user, array, user) }

    test_array = [
      { 'id' => '1234', 'actor' => { 'login' => 'user1' } },
      { 'id' => '5678', 'actor' => { 'login' => 'user1' } },
      { 'id' => '9012', 'actor' => { 'login' => 'user2' } }
    ]

    context 'array is nil' do
      let(:array) { nil }
      let(:user)  { DEFAULT_USER }

      it { is_expected.to eq [] }
    end

    context 'array is empty' do
      let(:array) { [] }
      let(:user)  { 'user2' }

      it { is_expected.to eq [] }
    end

    context 'disable refine' do
      let(:array) { test_array }
      let(:user)  { DEFAULT_USER }

      it { is_expected.to eq test_array }
    end

    context 'enable refine' do
      let(:array) { test_array }
      let(:user)  { 'user2' }

      expect_data = [{ 'id' => '9012', 'actor' => { 'login' => 'user2' } }]
      it { is_expected.to eq expect_data }
    end
  end

  describe 'refine_by_type' do
    subject { Glec.send(:refine_by_type, array, type) }

    test_array = [
      { 'id' => '1234', 'type' => 'Push' },
      { 'id' => '5678', 'type' => 'Push' },
      { 'id' => '9012', 'type' => 'Commit' }
    ]

    context 'array is nil' do
      let(:array) { nil }
      let(:type)  { DEFAULT_TYPE }

      it { is_expected.to eq [] }
    end

    context 'array is empty' do
      let(:array) { [] }
      let(:type)  { 'commit' }

      it { is_expected.to eq [] }
    end

    context 'disable refine' do
      let(:array) { test_array }
      let(:type)  { DEFAULT_TYPE }
      it { is_expected.to eq test_array }
    end

    context 'enable refine' do
      let(:array) { test_array }
      let(:type)  { 'commit' }

      it { is_expected.to eq [{ 'id' => '9012', 'type' => 'Commit' }] }
    end
  end

  describe '.get_latest_event' do
    subject { Glec.send(:get_latest_event, array) }

    context 'array is nil' do
      let(:array) { nil }
      it { is_expected.to eq({}) }
    end

    context 'array is empty' do
      let(:array) { [] }
      it { is_expected.to eq({}) }
    end

    context 'array is not empty' do
      let(:array) { [{ 'id' => '1234' }] }
      it { is_expected.to eq('id' => '1234') }
    end
  end

  describe '.start' do
    subject { Glec.start(owner: DEFAULT_OWNER, repo: DEFAULT_REPO) }

    let(:events) { '' }
    let(:events_array) { [] }
    let(:event) { {} }
    before do
      allow(Glec).to  receive(:get_events).and_return(events)
      allow(JSON).to  receive(:parse).and_return(events_array)
      allow(Glec).to  receive(:refine_by_user).and_return(events_array)
      allow(Glec).to  receive(:refine_by_type).and_return(events_array)
      allow(Glec).to  receive(:get_latest_event).and_return(event)
      allow(event).to receive(:[]).with('created_at').and_return('test_ok')
    end

    it { is_expected.to eq 'test_ok' }
  end
end

require_relative '../glec'

RSpec.describe Glec do
  describe '.get_events' do
    subject { proc { Glec.get_events(parameter) } }

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
      it { expect(Glec.get_events(parameter)).to eq res }
    end
  end

  describe '.start' do
    subject { Glec.start(owner: DEFAULT_OWNER, repo: DEFAULT_REPO) }
    before do
      methods = %w[
        get_events
        to_array_of_hash
        refine_by_user
        refine_by_type
        latest
        timestamp
        introduce
      ].join('.')
      allow(Glec).to receive_message_chain(methods).and_return('test_ok')
    end

    it { is_expected.to eq 'test_ok' }
  end
end

RSpec.describe Object do
  describe '#introduce' do
    message = 'test'
    let(:obj) { Object.new }
    before { allow(obj).to receive(:inspect).and_return(message) }
    it { expect { obj.introduce }.to output("#{message}\n").to_stdout }
  end
end

RSpec.describe String do
  describe '#to_array_of_hash' do
    let(:str)  { '[{"id": "1234"}, {"id": "5678"}]' }
    let(:hash) { [{ 'id' => '1234' }, { 'id' => '5678' }] }
    subject { str.to_array_of_hash }
    it { is_expected.to eq hash }
  end
end

RSpec.describe Array do
  describe '#refine_by_user' do
    let(:array) do
      [
        { 'id' => '1234', 'actor' => { 'login' => 'user1' } },
        { 'id' => '5678', 'actor' => { 'login' => 'user1' } },
        { 'id' => '9012', 'actor' => { 'login' => 'user2' } }
      ]
    end
    subject { array.refine_by_user(user) }

    context 'enable refine' do
      let(:user) { 'user2' }
      expect_data = [{ 'id' => '9012', 'actor' => { 'login' => 'user2' } }]
      it { is_expected.to eq expect_data }
    end

    context 'disable refine' do
      let(:user) { TARGET_ALL }
      it { is_expected.to eq array }
    end
  end

  describe '#refine_by_type' do
    let(:array) do
      [
        { 'id' => '1234', 'type' => 'Push' },
        { 'id' => '5678', 'type' => 'Push' },
        { 'id' => '9012', 'type' => 'Commit' }
      ]
    end
    subject { array.refine_by_type(type) }

    context 'enable refine' do
      let(:type) { 'commit' }
      it { is_expected.to eq [{ 'id' => '9012', 'type' => 'Commit' }] }
    end

    context 'disable refine' do
      let(:type) { TARGET_ALL }
      it { is_expected.to eq array }
    end
  end

  describe '#latest' do
    subject { array.latest }

    context 'array is empty' do
      let(:array) { [] }
      it { is_expected.to eq({}) }
    end

    context 'array is not empty' do
      let(:array) { [{ 'id' => '1234' }] }
      it { is_expected.to eq('id' => '1234') }
    end
  end
end

RSpec.describe Hash do
  describe '#timestamp' do
    test_data = 'test_data'
    let(:hash) { { 'created_at' => test_data } }
    subject { hash.timestamp }
    it { is_expected.to eq test_data }
  end
end

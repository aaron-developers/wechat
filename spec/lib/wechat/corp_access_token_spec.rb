require 'spec_helper'

RSpec.describe Wechat::CorpAccessToken do
  let(:token_file) { Rails.root.join('access_token') }
  let(:token) { '12345' }
  let(:client) { double(:client) }

  subject do
    Wechat::CorpAccessToken.new(client, 'corpid', 'corpsecret', token_file)
  end

  before :each do
    allow(client).to receive(:get)
      .with('gettoken', params: { corpid: 'corpid',
                                  corpsecret: 'corpsecret' }).and_return('access_token' => '12345', 'expires_in' => 7200)
  end

  after :each do
    File.delete(token_file) if File.exist?(token_file)
  end

  describe '#refresh' do
    specify 'will set access_token' do
      got_token_at = Time.now.to_i
      expect(subject.refresh).to eq(token)
      expect(subject.access_token).to eq('12345')
    end

    specify "won't set access_token if request failed" do
      allow(client).to receive(:get).and_raise('error')

      expect { subject.refresh }.to raise_error('error')
      expect(subject.access_token).to be_nil
    end

    specify "won't set access_token if response value invalid" do
      allow(client).to receive(:get).and_return('rubbish')

      expect { subject.refresh }.to raise_error
      expect(subject.access_token).to be_nil
    end
  end
end

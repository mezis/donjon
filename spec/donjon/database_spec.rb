require 'spec_helper'
require 'spec/support/keys'
require 'spec/support/repos'
require 'donjon/database'
require 'donjon/user'

describe Donjon::Database do
  let_repo :repo

  let(:actor) {
    Donjon::User.new(name: 'alice', key: random_key, repo: repo).save
  }

  let(:options) {{
    actor: actor
  }}

  subject { described_class.new(**options) }

  describe '#initialize' do
    it 'passes with valid options' do
      expect { subject }.not_to raise_error
    end

    it 'requires :actor' do
      options.delete :actor
      expect { subject }.to raise_error
    end
  end

  describe '#[]=' do
    it 'passes' do
      expect {
        subject['foo'] = 'bar'
      }.not_to raise_error
    end
  end

  describe '#[]' do
    it 'returns nil is nothing saved' do
      expect( subject['foo1'] ).to be_nil
    end

    it 'returns nil if nil saved' do
      subject['foo2'] = nil
      expect( subject['foo2'] ).to be_nil
    end

    it 'returns previously save values' do
      subject['foo3'] = 'bar3'
      expect( subject['foo3'] ).to eq('bar3')
    end
  end
end

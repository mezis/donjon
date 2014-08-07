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

  let(:other_user) {
    Donjon::User.new(name: 'bob', key: random_key, repo: repo).save
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

    it 'deletes key when passed nil' do
      subject['foo'] = 'bar'
      subject['foo'] = nil
      expect(subject['foo']).to be_nil
      expect(subject.to_a).to be_empty
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

    it 'returns nil when the key is not readable' do
      subject['foo4'] = 'bar4'
      other_db = described_class.new(actor: other_user)
      expect(other_db['foo4']).to be_nil
    end
  end

  describe '#update' do
    it 'makes keys reable for other users' do
      subject['foo'] = 'bar'
      other_db = described_class.new(actor: other_user)
      subject.update
      expect(other_db['foo']).to eq('bar')
    end
  end

  describe '#each' do
  end
end

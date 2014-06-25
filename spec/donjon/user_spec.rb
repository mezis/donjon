require 'spec_helper'
require 'donjon/user'
require 'donjon/repository'
require 'spec/support/repos'
require 'spec/support/keys'

describe Donjon::User do
  let_repo(:repo)

  let(:options) {{
    name:    'john-doe',
    key:     random_key,
    repo:    repo
  }}

  subject { described_class.new(**options) }

  describe '#initialize' do
    it 'passes with valid arguments' do
      expect { subject }.not_to raise_error
    end
  end

  describe '#save' do
    it 'passes' do
      expect { subject.save }.not_to raise_error
    end

    it 'creates public key file' do
      subject.save
      expect( repo.join('users/john-doe.pub') ).to be_exist
    end

    it 'does not save the private key' do
      subject.save
      data = repo.join('users/john-doe.pub').read
      expect(data).to match(/PUBLIC KEY/)
      expect(data).not_to match(/PRIVATE KEY/)
    end

    xit 'fails if existing, different key'
  end

  describe '.find' do
    context 'with no users' do
      it 'returns nil' do
        expect(
          described_class.find(name: 'bob', repo: repo)
        ).to be_nil
      end
    end

    context 'with users' do
      let(:bob_key) { random_key }

      before do
        Donjon::User.new(name: 'alice', key: random_key, repo: repo).save
        Donjon::User.new(name: 'bob',   key: bob_key,    repo: repo).save
      end

      it 'returns nil for unknown users' do
        expect(
          described_class.find(name: 'charlie', repo: repo)
        ).to be_nil
      end

      it 'returns known users' do
        bob = described_class.find(name: 'bob', repo: repo)
        expect(bob.name).to eq('bob')
        expect(bob.key.to_pem).to  eq(bob_key.public_key.to_pem)
      end
    end
  end

  describe '.each' do
    context 'with no users' do
      it 'returns nil' do
        expect { |b|
          described_class.each(repo, &b)
        }.not_to yield_control
      end
    end

    context 'with users' do
      before do
        Donjon::User.new(name: 'alice', key: random_key, repo: repo).save
        Donjon::User.new(name: 'bob',   key: random_key, repo: repo).save
      end

      it 'returns known users' do
        expect { |b|
          described_class.each(repo, &b)
        }.to yield_successive_args(Donjon::User, Donjon::User)
      end
    end
  end

end

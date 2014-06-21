require 'spec_helper'
require 'donjon/user'
require 'donjon/repository'
# require 'spec/support/repos'

def random_repo
  id = OpenSSL::Random.random_bytes(4).unpack('L').first.to_s(16)
  Donjon::Repository.new("tmp/repo-#{id}")
end

def random_key
  OpenSSL::PKey::RSA.new(2048)
end


describe Donjon::User do
  let(:repo) { random_repo }
  after { repo.rmtree if repo.exist? }

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

    it 'creates users.yml' do
      subject.save
      expect( repo.join('users.yml') ).to be_exist
    end

    it 'does not save the private key' do
      subject.save
      data = repo.join('users.yml').read
      expect(data).to match(/PUBLIC KEY/)
      expect(data).not_to match(/PRIVATE KEY/)
    end
  end

  describe '.find' do
    context 'with no users' do
      it 'returns nil'
    end

    context 'with users' do
      it 'returns nil for unknown users'
      it 'returns known users'
    end
  end

  describe '.each'

end

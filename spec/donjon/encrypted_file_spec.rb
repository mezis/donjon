require 'spec_helper'
require 'donjon/encrypted_file'
require 'donjon/user'
require 'spec/support/repos'
require 'spec/support/keys'

describe Donjon::EncryptedFile do
  let_repo :repo

  let(:actor) {
    Donjon::User.new(key: random_key, name: 'alice', repo: repo)
  }

  let(:other_user) {
    Donjon::User.new(key: random_key, name: 'bob', repo: repo)
  }

  let(:options) {{
    path: 'foo', actor: actor
  }}

  subject { described_class.new(**options) }

  describe '#initialize' do
    it 'passes with valid options' do
      expect { subject }.not_to raise_error
    end

    it 'requires :path' do
      options.delete :path
      expect { subject }.to raise_error
    end

    it 'requires :actor' do
      options.delete :actor
      expect { subject }.to raise_error
    end
  end

  describe '#write' do
    before { actor.save } 

    it 'passes' do
      expect { subject.write('foo') }.not_to raise_error
    end

    it 'passes with large data' do
      expect { subject.write('foo' * 1024) }.not_to raise_error
    end

    it 'works twice' do
      expect {
        2.times { subject.write 'foo' }
      }.not_to raise_error
    end
  end

  describe '#read' do
    before do
      actor.save
      other_user.save

      described_class.
        new(actor: actor, path: options[:path]).
        write('hello, world!')
    end


    it 'returns decrypted contents' do
      expect(subject.read).to eq('hello, world!')
    end

    it 'works for other users' do
      data = described_class.
        new(actor: other_user, path: options[:path]).
        read
      expect(data).to eq('hello, world!')
    end
  end

  describe '#readable?' do
    let(:other_file) {
      described_class.new(actor: other_user, path: options[:path])
    }

    before { actor.save }
    
    it 'is false for non-existing files' do
      expect(subject).not_to be_readable
    end

    it 'is true for files I wrote' do
      subject.write 'foo'
      expect(subject).to be_readable
    end

    it 'is false for users added after I wrote' do
      subject.write 'foo'
      expect(other_file).not_to be_readable
    end

    it 'is true for users added before I wrote' do
      other_user.save
      subject.write 'foo'
      expect(other_file).to be_readable
    end
  end
end



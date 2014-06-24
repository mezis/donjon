require 'spec_helper'
require 'donjon/repository'

describe Donjon::Repository do
  let(:uid) { "%08x" % rand(1<<32) }
  let(:options) {[
    "/tmp/donjon-#{uid}"
  ]}

  subject { described_class.new(*options) }

  describe '#initialize' do
    it 'passes with valid options' do
      expect { subject }.not_to raise_error
    end
  end

  describe '#to_s' do
    it 'returns the path' do
      expect(subject.to_s).to eq(options.first)
    end
  end
end


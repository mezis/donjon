require 'spec_helper'
require 'openssl'
require 'donjon/repository'



def let_repo(name)
  let(name) do
    id = OpenSSL::Random.random_bytes(4).unpack('L').first.to_s(16)
    Donjon::Repository.new("tmp/repo-#{id}")
  end

  after do
    send(name).tap do |repo|
      repo.rmtree if repo.exist?
    end
  end
end

# def random_key
#   OpenSSL::PKey::RSA.new(2048)
# end




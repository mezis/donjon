require 'spec_helper'
require 'openssl'
require 'donjon/repository'



def let_repo(name)
  let(name) do
    id = "%08x" % rand(1<<32)
    Donjon::Repository.new("tmp/repo-#{id}")
  end

  after do
    send(name).tap do |repo|
      repo.rmtree if repo.exist?
    end
  end
end





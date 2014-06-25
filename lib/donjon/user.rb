require 'yaml'
require 'core_ext/assert'

module Donjon
  class User
    attr_reader :name, :key, :repo

    def initialize(name:, key:, repo:)
      assert(key.n.num_bits == 2048)
      
      @name  = name
      @key   = key
      @repo  = repo
    end

    def save
      _path_for(@name, @repo).tap do |path|
        path.parent.mkpath
        path.write @key.public_key.to_pem
      end
      self
    end

    private

    module SharedMethods
      private 

      def _path_for(name, repo)
        repo.join("users/#{name}.pub")
      end
    end
    extend SharedMethods
    include SharedMethods

    module ClassMethods
      def find(name:, repo:)
        path = _path_for(name, repo)
        return unless path.exist?
        key = OpenSSL::PKey::RSA.new(path.read)
        new(name: name, key: key, repo: repo)
      end

      def each(repo, &block)
        container = repo.join('users')
        return unless container.exist?
        container.children.each do |child|
          next unless child.extname == '.pub'
          name = child.basename.to_s.chomp('.pub')
          key = OpenSSL::PKey::RSA.new(child.read)
          block.call new(name: name, key: key, repo: repo)
        end
      end
    end
    extend ClassMethods
  end



end


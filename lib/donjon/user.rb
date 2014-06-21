require 'yaml'

module Donjon
  class User
    attr_reader :name, :pubkey, :privkey, :repo

    def initialize(name:, pubkey:, repo:, privkey: nil)
      @name    = name
      @pubkey  = pubkey
      @repo    = repo
      @privkey = privkey
      # TODO: assert key is 2048 bits
    end

    def save
      data = _load(@repo)
      data[name] = @pubkey.to_pem
      _save(data, @repo)
      self
    end

    module SharedMethods
      private 

      def _load(repo)
        path = _path(repo)
        data = path.exist? ? YAML.load_file(path) : {}
      end

      def _save(data, repo)
        _path(repo).parent.mkpath
        _path(repo).write(data.to_yaml)
      end

      def _path(repo)
        repo.join('users.yml')
      end
    end
    extend SharedMethods
    include SharedMethods

    module ClassMethods
      def find(name:, repo:)
        data = _load(repo)
        return unless data[name]
        key = OpenSSL::PKey::RSA.new(data[name])
        new(name: name, pubkey: key, repo: repo)
      end

      def each(repo, &block)
        _load(repo).each_pair do |name, pem|
          key = OpenSSL::PKey::RSA.new(pem)
          block.call new(name: name, pubkey: key, repo: repo)
        end
      end
    end
    extend ClassMethods
  end



end


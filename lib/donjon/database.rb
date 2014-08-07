require 'donjon/encrypted_file'
require 'json'

module Donjon
  class Database
    include Enumerable

    def initialize(actor:)
      @actor = actor
    end

    def [](key)
      file = _file(key)
      return unless file.readable? 
      _key, value = _unpack(file.read)
      assert(key == _key, "bad stored data for #{key}!")
      return value
    end

    def []=(key, value)
      if value.nil?
        _file(key).write(nil)
      else
        _file(key).write(_pack(key, value))
      end
    end

    def each
      parent = @actor.repo.join('data')
      return unless parent.exist?
      parent.children.each do |child|
        path = "data/#{child.basename}"
        file = EncryptedFile.new(path: path, actor: @actor)
        next unless file.readable?
        yield *_unpack(file.read)
      end
    end

    def update
      each do |key, value|
        self[key] = value
      end
      nil
    end


    private

    def _pack(key, value)
      JSON.dump([key, value])
    end

    def _unpack(data)
      JSON.parse(data)
    end

    def _hash(key)
      OpenSSL::Digest::SHA256.hexdigest(key)
    end

    def _file(key)
      EncryptedFile.new(path: "data/#{_hash(key)}", actor: @actor)
    end
  end
end

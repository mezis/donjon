require 'donjon/encrypted_file'

module Donjon
  class Database
    def initialize(actor:)
      @actor = actor
    end

    def [](key)
      _file(key).tap do |f|
        return f.exist? ? f.read : nil
      end
    end

    def []=(key, value)
      _file(key).write(value)
    end

    private

    def _hash(key)
      OpenSSL::Digest::SHA256.hexdigest(key)
    end

    def _file(key)
      EncryptedFile.new(path: "data/#{_hash(key)}", actor: @actor)
    end
  end
end

require 'openssl'
require 'gibberish'
require 'core_ext/assert'
require 'digest'

module Donjon
  class EncryptedFile
    def initialize(path:, actor:)
      @path = path
      @actor = actor
    end

    def exist?
      _base_path.exist?
    end

    def readable?
      _path_for(@actor).exist?
    end

    def read
      path = _path_for(@actor)
      exist? or raise 'file does not exist'
      path.exist? or raise 'you were not granted access'
      data = path.binread
      _decrypt_from(@actor, data)
    end

    def write(data)
      if data.nil?
        _base_path.rmtree if exist?
        return
      end

      User.each(@actor.repo) do |user|
        payload = _encrypt_for(user, data)
        path = _path_for(user)
        path.parent.mkpath
        path.binwrite(payload)
      end
    end

    private

    # encrypted file format:
    # - 256 B           encrypted AES key
    # - variable        payload
    # payload format:
    # - 32 B            encoding
    # - variable        data
    # - PADDING B       padding

    # random bytes added to the data to encrypt to obfuscate it
    PADDING = 256

    def _decrypt_from(user, data)
      encrypted_key  = data[0...256]
      encrypted_data = data[256..-1]

      decrypted_pw = user.key.private_decrypt(encrypted_key)

      assert(decrypted_pw.size == 32)
      payload = Gibberish::AES.new(decrypted_pw).decrypt(encrypted_data, binary: true)
      encoding = payload[0...32].strip
      payload[32...-PADDING].force_encoding(encoding)
    end

    def _encrypt_for(user, data)
      encoding = data.encoding
      data = data.force_encoding(Encoding::BINARY)

      encoding_field = ("%-32s" % encoding).force_encoding(Encoding::BINARY)
      payload = encoding_field + data + OpenSSL::Random.random_bytes(PADDING)
      password = OpenSSL::Random.random_bytes(32)
      encrypted_data = Gibberish::AES.new(password).encrypt(payload, binary: true)
      
      encrypted_key = user.key.public_encrypt(password)

      assert(encrypted_key.size == 256)
      encrypted_key + encrypted_data
    end

    def _log_key(message, key)
      puts "#{message}: #{key.bytesize} bytes"
      puts key.bytes.map { |b| "%02x" % b }.join(":")
    end

    def _base_path
      @actor.repo.join(@path)
    end

    def _path_for(user)
      _base_path.join("#{user.name}.db")
    end
  end
end

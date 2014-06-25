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

    # random bytes added to the data to encrypt to obfuscate it
    PADDING = 256

    def _decrypt_from(user, data)
      encrypted_key  = data[0...256]
      encrypted_data = data[256..-1]

      # _log_key "before decrypt", encrypted_key
      decrypted_pw = user.key.private_decrypt(encrypted_key)
      # _log_key "decrypted", decrypted_pw

      assert(decrypted_pw.size == 32)
      payload = Gibberish::AES.new(decrypted_pw).decrypt(encrypted_data, binary: true)
      payload[0...-PADDING]
    end

    def _encrypt_for(user, data)
      payload = data + OpenSSL::Random.random_bytes(PADDING)
      password = OpenSSL::Random.random_bytes(32)
      encrypted_data = Gibberish::AES.new(password).encrypt(payload, binary: true)
      
      # _log_key "before crypto", password
      encrypted_key = user.key.public_encrypt(password)
      # _log_key "encrypted", encrypted_key

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

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

    def read
      path = _path_for(@actor)
      path.exist? or raise 'not readable by you, or does not exist'
      data = path.binread
      _decrypt_from(_last_writer, data)
    end

    def write(data)
      User.each(@actor.repo) do |user|
        payload = _encrypt_for(user, data)
        path = _path_for(user)
        path.parent.mkpath
        path.binwrite(payload)
      end
      _last_writer_path.write(@actor.name)
    end

    private

    def _decrypt_from(user, data)
      encrypted_key  = data[0...256]
      encrypted_data = data[256..-1]

      # puts "encrypted key is #{encrypted_key.size} bytes"
      # puts "encrypted key: #{Digest::MD5.hexdigest encrypted_key}"
      # puts "decrypt with pubkey #{user.name}"
      half_decrypted_pw = user.key.public_decrypt(encrypted_key, OpenSSL::PKey::RSA::NO_PADDING)
      # puts "decrypt with privkey #{@actor.name}"
      decrypted_pw = @actor.key.private_decrypt(half_decrypted_pw)

      Gibberish::AES.new(decrypted_pw).decrypt(encrypted_data, binary: true)
    end

    def _encrypt_for(user, data)
      password = OpenSSL::Random.random_bytes(16)
      encrypted_data = Gibberish::AES.new(password).encrypt(data, binary: true)
      
      # puts "encrypt with pubkey #{user.name}"
      half_encrypted_key = user.key.public_encrypt(password)
      # puts "encrypt with privkey #{@actor.name}"
      encrypted_key = @actor.key.private_encrypt(half_encrypted_key, OpenSSL::PKey::RSA::NO_PADDING)
      # puts "encrypted key: #{Digest::MD5.hexdigest encrypted_key}"
      assert(encrypted_key.size == 256)
      encrypted_key + encrypted_data
    end

    def _path_for(user)
      user.repo.join(@path).join("#{user.name}.db")
    end

    def _last_writer_path
      @actor.repo.join(@path).join('last_writer')
    end

    def _last_writer
      raise 'nothing written' unless _last_writer_path.exist?
      User.find name: _last_writer_path.read, repo: @actor.repo
    end
  end
end

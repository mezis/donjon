require 'openssl'

def random_key
  OpenSSL::PKey::RSA.new(2048)
end



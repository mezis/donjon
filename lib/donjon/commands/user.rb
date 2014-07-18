require 'donjon/commands/base'
require 'donjon/user'

module Donjon
  module Commands
    Base.class_eval do
      desc 'user:add NAME [PATH]', 'Adds user and their public key to the vault. Reads from standard input if no path is given.'
      decl 'user:add'

      desc 'user:key', 'Prints your public key'
      decl 'user:key'

      private
      
      def user_add(name, path = nil)
        if path == nil
          say "Please paste #{name}'s public key in PEM format.", :green
          say "They can obtain it by running e.g.:"
          say "$ openssl rsa -in ~/.ssh/id_rsa -pubout -outform pem"
          $stderr.write('> ')
          key_data = ''
          while line = $stdin.gets
            break if line.strip.empty?
            key_data << line
          end
        else
          key_data = Pathname.new(path).expand_path.read
        end

        key = OpenSSL::PKey::RSA.new(key_data, '').public_key
        say "Saving #{name}'s public key..."
        User.new(name: name, key: key, repo: actor.repo).save
        say "Making the database readable by #{name}..."
        database.update
        say "Success! #{name} has been added to the vault.", [:green, :bold]
      end

      def user_key
        puts actor.key.public_key.to_pem 
      end
    end
  end
end

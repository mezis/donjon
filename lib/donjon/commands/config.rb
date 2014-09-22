require 'donjon/commands/base'

module Donjon
  module Commands
    Base.class_eval do
      desc 'config:mset KEY=VALUE ...', 'Encrypts KEY and VALUE in the vault'
      decl 'config:mset'

      desc 'config:set KEY', 'Reads a VALUE from standard input, encrypts KEY and VALUE in the vault'
      decl 'config:set'

      desc 'config:fset KEY FILE', 'Encrypts KEY and the contents of FILE in the vault'
      decl 'config:fset'

      desc 'config:get KEY...', 'Decrypts the value for KEY from the vault'
      decl 'config:get'
      
      desc 'config:mget [REGEXP]', 'Decrypts multiple keys (all readable by default)'
      decl 'config:mget'
      
      desc 'config:del KEY', 'Removes a key-value pair'
      decl 'config:del'
      
      private
      
      def config_mset(*keyvals)
        keyvals.each do |keyval|
          m = /([^=]*)=(.*)/.match(keyval)
          if m.nil?
            say "Misformatted key-value pair '#{keyval}'"
            exit 1
          end
          key = m[1]
          value = m[2]
          database[key] = value
        end
        say "Warning: the keys and values you just set may be saved to your shell history", :red
        say "You can clear your history by running `history -c`."
      end

      def config_set(key)
        value = _get_password("Please enter the value for '#{key}'")
        database[key] = value
      end

      def config_fset(key, path)
        database[key] = Pathname(path).read
      end

      def config_get(*keys)
        keys.each do |key|
          puts "#{key}: #{database[key]}"
        end
      end

      def config_mget(regexp = nil)
        regexp = Regexp.new(regexp) if regexp
        database.each do |key, value|
          next if regexp && regexp !~ key
          puts "#{key}: #{value}"
        end
      rescue RegexpError => e
        say "Misformatted regular expression '#{regexp}'", :red
        say "(#{e.message})"
        exit 1
      end

      def config_del(key)
        database[key] = nil
      end
    end
  end
end

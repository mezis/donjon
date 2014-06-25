require 'donjon/commands/base'

module Donjon
  module Commands
    Base.class_eval do
      desc 'config:set KEY=VALUE ...', 'encrypts KEY and VALUE in the repo'
      decl 'config:set'

      desc 'config:get KEY...', 'decrypts the value for KEY from the repo'
      decl 'config:get'
      
      desc 'config:mget [REGEXP]', 'decrypts multiple keys (default all readable)'
      decl 'config:mget'
      
      private
      
      def config_set(*keyvals)
        keyvals.each do |keyval|
          m = /([^=]*)=(.*)/.match(keyval)
          key = m[1]
          value = m[2]
          database[key] = value
        end
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
      end
    end
  end
end

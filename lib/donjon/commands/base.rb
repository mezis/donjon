require 'donjon/shell'
require 'donjon/settings'
require 'pathname'
require 'pathname'
require 'openssl'
require 'donjon/user'
require 'donjon/database'
require 'core_ext/io_get_password'

module Donjon
  module Commands
    class Base < Thor
      def self.start(args)
        super(args, shell: Shell.instance)
      end

      def self.decl(method_name)
        define_method(method_name.to_sym) { |*args| send(method_name.gsub(':','_').to_sym, *args) }
      end

      protected

      def settings
        @settings ||= Settings.new
      end

      def check_configured
        return if settings.configured?
        say "Oops, I can't run that until you've configured me.", :red
        say "Run 'vault:init' and I'll help out!"
        exit 1
      end

      def repo
        @repo ||= begin
          check_configured
          Repository.new(settings.vault_path)
        end
      end

      def actor
        @actor ||= begin
          check_configured
          pem_data = Pathname.new(settings.private_key).read
          password = _get_password("Please enter the password for your private key (#{settings.private_key})")
          key = OpenSSL::PKey::RSA.new(pem_data, password)
          User.new(repo: repo, name: settings.user_name, key: key)
        end
      end

      def database
        @database ||= begin
          Database.new(actor: actor)
        end
      end

      def _get_password(message)
        say message, :green
        $stdout.write('> ')
        $stdin.get_password
      end
    end
  end
end

require 'donjon/user'
require 'core_ext/io_get_password'
require 'ostruct'

module Donjon
  class Configurator
    def initialize(settings:)
      @settings = settings
    end

    def run
      _get_name
      _get_repo
      _get_private_key_path
      _save_user
      _thank_user if changes?
      nil
    end

    private

    def changes?
      !!@changes
    end

    def changes!
      @changes = true
    end

    def _thank_user
      _shell.say "Thanks! All your settings are saved.", [:green, :bold]
    end

    def _get_repo
      path = @settings.vault_path ||= begin
        changes!
        _shell.say "Where do you want your vault? [~/.donjon]", :green
        ans = _shell.ask('>')
        ans = '~/.donjon' if ans.empty?
        Pathname.new(ans).expand_path.to_s
      end
      Donjon::Repository.new(path)
    end

    def _get_name
      @settings.user_name ||= begin
        changes!
        _shell.say "Hi! How do you want to be called? [#{_default_name}]", :green
        ans = _shell.ask '>'
        ans.empty? ? _default_name : ans
      end
    end

    def _get_private_key_path
      @settings.private_key ||= begin
        changes!
        _get_key_path.path.to_s
      end
    end

    def _get_key_path
      @_key_path ||= begin
        _shell.say [
          'Do you want to use an existing private key or create one?',
          'If you use an existing key, it needs to be an encrypted, 2048-bit RSA key.',
          'Use [e]xisting or [c]reate?',
        ].join("\n"), :green
        ans = _shell.ask('>')

        case ans
        when /[Ee]/
          _get_existing_key
        when /[Cc]/
          _get_new_key
        else
          _shell.say 'No idea what you mean, sorry.', :red
          exit 1
        end
      end
    end

    def _get_existing_key
      _shell.say('What is the path to your key? [~/.ssh/id_rsa]', :green)
      ans = _shell.ask('>')
      ans = '~/.ssh/id_rsa' if ans.empty?
      path = Pathname.new(ans).expand_path
      if !path.exist?
        _shell.say 'Sorry, cannot find that file.', :red
        exit 1
      end
      _check_key(path)
    end


    def _check_key(path, password = nil)
      unless _is_key_encrypted?(path)
        _shell.say 'That key is not password-protected. Sorry, I\' not taking that risk!', :red
        exit 1
      end

      if password.nil?
        _shell.say "I'll now try to load your private key.", :green
        _shell.say "Please enter your key password (I won't store it anywhere)", :green
        $stdout.write "> "
        $stdout.flush
        password = $stdin.get_password
      end

      key = OpenSSL::PKey::RSA.new(path.read, password)
      if key.n.num_bits != 2_048
        _shell.say "Sorry, that key isn't 2,048 bits long.", :red
        exit 1
      end

      _shell.say "Okay, that key seems valid.", :green
      OpenStruct.new key: key.public_key, path: path
    end

    def _get_new_key
      _shell.say "Where do you want to store your new key? [~/.ssh/donjon_rsa]", :green
      ans = _shell.ask('>')
      ans = '~/.ssh/donjon_rsa' if ans.empty?
      path = Pathname.new(ans).expand_path

      _shell.say "Please enter a password for your new key (I won't store it anywhere)", :green
      $stdout.write "> "
      $stdout.flush
      password = $stdin.get_password
      
      command = "ssh-keygen -q -t rsa -b 2048 -N '#{password}' -f #{path}"
      unless system(command)
        _shell.say "Sorry, key generation failed!", :red
        exit 1
      end

      _check_key(path, password)
    end

    def _save_user
      if user = User.find(repo: _get_repo, name: _get_name)
        if user.key.to_pem.strip != _get_key_path.key.to_pem.strip
          _shell.say "There's already a user with your name in the vault, and the public keys don't match. I'm afraid I'm a bit stumped.", :red
          exit 1
        end
        return
      end
      User.new(name: _get_name, repo: _get_repo, key: _get_key_path.key).save
      nil
    end

    def _is_key_encrypted?(path)
      OpenSSL::PKey::RSA.new(path.read, '')
      return false
    rescue OpenSSL::PKey::RSAError
      return true
    end

    def _default_name
      ENV['USER'] || ENV['LOGNAME']
    end

    def _shell
      Shell.instance
    end
  end
end

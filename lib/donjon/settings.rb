require 'yaml'

module Donjon
  class Settings
    attr_reader :path

    def initialize(path = nil)
      @path = path || _default_path
      @data = nil
    end

    def configured?
      user_name && private_key && vault_path
    end

    def method_missing(method_name, *args, &block)
      if method_name.to_s.end_with?('=')
        set(method_name.to_s.chop, *args)
      else
        get(method_name.to_s, *args)
      end
    end

    def respond_to?(method_name)
      !!(method_name.to_s =~ /[a-z][a-z_]*=?/)
    end

    private

    def get(key)
      @data ||= _load
      @data[key]
    end

    def set(key, value)
      @data ||= _load
      @data[key] = value
      _save(@data)
      value
    end

    def _load
      @path.exist? ? YAML.load_file(@path) : {}
    end
    
    def _save(data)
      @data['timestamp'] = Time.now
      @path.parent.mkpath
      @path.write data.to_yaml
    end

    def _fallback_path
      Pathname.new('~').join('.donjonrc').expand_path
    end

    def _default_path
      ENV.fetch('DONJONRC', _fallback_path)
    end
  end
end

module Donjon
  class Database
    def initialize(path:, reader:)
    end

    def get(key)
      _data[key]
    end

    def set(key, value)
      _data[key] = value
    end

    def save
      # yaml = @data.to_yaml
    end

    private

    def _data
      @_data ||= begin
        raw = EncryptedFile.new(path: @path, reader: @reader).read
        YAML.load(raw)
      end
    end
  end
end

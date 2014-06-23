require 'pathname'

module Donjon
  class Repository < Pathname
    attr_reader :path

    def initialize(path)
      @path = path
    end
  end
end

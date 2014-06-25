require 'thor'
require 'delegate'
require 'singleton'

module Donjon
  class Shell < SimpleDelegator
    include Singleton

    def initialize
      shell = if $stdout.tty?
        Thor::Shell::Color.new
      else
        Thor::Shell::Basic.new
      end
      super(shell)
    end
  end
end


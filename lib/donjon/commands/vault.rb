require 'thor'
require 'pathname'
require 'donjon/commands/base'
require 'donjon/repository'
require 'donjon/settings'
require 'donjon/configurator'
require 'donjon/shell'

module Donjon
  module Commands
    Base.class_eval do
      desc "init", 'Creates a new vault, or connects to an existing vault.'
      
      def init
        if settings.configured?
          say 'This vault is already configured :)', :green
          say 'If you want another one, set DONJONRC to a new configuration file'
          say "(if it doesn't exist I will create one for you)"
          return
        end

        Configurator.new(settings: settings).run
      end


    end
  end
end

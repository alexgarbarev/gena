
require 'thor'

## Base class for all plugins

module Gena

  class Plugin < Thor

    def self.setup_thor_commands
      app_klass = Gena::Application
      app_klass.commands.merge!(self.commands)
      self.commands.each do |key, value|
        hash = app_klass.class_for_command
        hash[key] = self
        app_klass.class_for_command = hash
      end
    end

    def self.descendants
      ObjectSpace.each_object(Class).select { |klass| klass < self }
    end
  end

end
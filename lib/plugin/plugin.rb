require 'thor'

## Base class for all plugins

module Gena

  class Plugin < Thor

    @gena_config
    @config

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

    no_tasks do

      def config
        config = $config.data
        config.except(GENA_PLUGINS_CONFIG_KEY)
      end

      def plugin_config
        # puts "Class: #{self.class.plugin_config_name}"
        $config.data[GENA_PLUGINS_CONFIG_KEY][self.class.plugin_config_name]
      end

      def self.plugin_config_name
        self.name.split("::").last.underscore
      end

      def self.plugin_config_defaults
        Hash.new
      end

    end

  end

end
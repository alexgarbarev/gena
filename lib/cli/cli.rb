require 'thor'


module Gena

  class Module < Plugin
    desc 'module MODULE_NAME', 'Generates VIPER module with given name'
    method_option :scope, :banner => 'NAME', :desc => 'Defines subdirectory for module'

    def module(name)
      puts "Module name: #{name}, options: #{options}"
    end
  end


  class Fonts < Plugin
    desc 'fonts', 'Adds custom fonts to the projects and creates category'
    def fonts
      puts 'Fonts updated!'
    end
  end

end



module Gena

  class Application < Thor

    class << self
      # class_for_command - hash to store custom classes (actually Plugin subclasses) for each
      # command registered with gena

      def class_for_command
        @class_for_command ||= Hash.new
      end

      def class_for_command=(commands)
        @class_for_command = commands
      end

      # Override help to forward

      def help(shell, subcommand = false)

        #List plugin commands separately from Gena general commands
        plugins = []
        class_for_command.each do |command, klass|
          plugins += klass.printable_commands(false)
        end

        list = printable_commands(true, subcommand)
        Thor::Util.thor_classes_in(self).each do |klass|
          list += klass.printable_commands(false)
        end

        list -= plugins

       # Remove this line to disable alphabetical sorting
        # list.sort! { |a, b| a[0] <=> b[0] }

        # Add this line to remove the help-command itself from the output
        # list.reject! {|l| l[0].split[1] == 'help'}

        if defined?(@package_name) && @package_name
          shell.say "#{@package_name} commands:"
        else
          shell.say "General commands:"
        end

        shell.print_table(list, :indent => 2, :truncate => true)
        shell.say
        class_options_help(shell)

        shell.say "Plugins:"
        shell.print_table(plugins, :indent => 2, :truncate => true)
      end


      # Override start to load plugins and do custom dispatch (looking for plugin for unknown command)

      def start(given_args = ARGV, config = {})
        load_plugins

        config[:shell] ||= Thor::Base.shell.new

        command_name = normalize_command_name(retrieve_command_name(given_args.dup))
        clazz = command_name ? class_for_command[command_name] : nil

        if command_name && clazz
          clazz.dispatch(nil, given_args.dup, nil, config)
        else
          dispatch(nil, given_args.dup, nil, config)
        end

      rescue Thor::Error => e
        config[:debug] || ENV["THOR_DEBUG"] == "1" ? (raise e) : config[:shell].error(e.message)
        exit(1) if exit_on_failure?
      rescue Errno::EPIPE
        # This happens if a thor command is piped to something like `head`,
        # which closes the pipe when it's done reading. This will also
        # mean that if the pipe is closed, further unnecessary
        # computation will not occur.
        exit(0)
      end

      def load_plugins
        Gena::Plugin.descendants.each do |clazz|
          clazz.setup_thor_commands
        end
      end

    end

  end

end




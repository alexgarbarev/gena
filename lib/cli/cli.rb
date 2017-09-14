require 'thor'


## Base class for all plugins

module Gena

  class Plugin < Thor

    def self.setup_thor_commands(thor_class)

      # puts "Class commands: #{thor_class.commands}"
      # puts "Self commands: #{self.commands}"

      thor_class.commands.merge!(self.commands)

      self.commands.each do |key, value|
        hash = Gena::Application.class_for_command
        hash[key] = self
        Gena::Application.class_for_command = hash
      end
      # puts "Hash: #{Gena::Application.class_for_command}"


      # puts "Then class commands: #{thor_class.commands}"

      # # Adding methods to thor application class.
      # self_ref = self
      # puts "self: #{self_ref}"
      # thor_class.class_eval do
      #   puts "eval self: #{self}"
      #   self_ref.thor_commands
      # end
    end

    # def self.thor_commands
    #
    #
    #
    # end

  end

end

module Gena

  class Module < Plugin

    desc 'module MODULE_NAME', 'Generates VIPER module with given name'
    method_option :scope, :banner => 'NAME', :desc => 'Defines subdirectory for module'

    def module(name)
      puts "Module name: #{name}, options: #{options}"
    end


  end

end


# module Gena
#
#   class Plugin < Thor
#
#
#     desc 'module MODULE_NAME', 'Generates VIPER module with given name'
#     method_option :scope, :banner => 'NAME', :desc => 'Defines subdirectory for module'
#     def module(name)
#       puts "Module name: #{name}, options: #{options}"
#     end
#
#   end
#
# end


# module Gena
#
#   class Plugin < Thor
#
#
#     desc 'fonts', 'Adds custom fonts to the projects and creates category'
#
#     def fonts
#       puts 'Fonts updated!'
#       private_m
#     end
#
#     no_commands do
#
#
#       def private_m
#
#       end
#
#     end
#
#   end
#
# end


module Gena


  class Application < Thor


    class << self

      def class_for_command
        @class_for_command ||= Hash.new
      end

      def class_for_command=(commands)
        @class_for_command = commands
      end


      # attr_accessor :class_for_command

      def help(shell, subcommand = false)
        list = printable_commands(true, subcommand)
        Thor::Util.thor_classes_in(self).each do |klass|
          list += klass.printable_commands(false)
        end


        # puts "Com: #{Module.printable_commands(false)}"

        # Remove this line to disable alphabetical sorting
        # list.sort! { |a, b| a[0] <=> b[0] }

        # Add this line to remove the help-command itself from the output
        # list.reject! {|l| l[0].split[1] == 'help'}

        if defined?(@package_name) && @package_name
          shell.say "#{@package_name} commands:"
        else
          shell.say "Commands:"
        end

        shell.print_table(list, :indent => 2, :truncate => true)
        shell.say
        class_options_help(shell)

        # List plugin commands separately from Gena general commands
        # plugins = []
        # Thor::Util.thor_classes_in(Gena::Plugin).each do |klass|
        #   plugins += klass.printable_commands(false)
        # end
        # shell.say "Plugins:"
        # shell.print_table(plugins, :indent => 2, :truncate => true)

        # Add this line if you want to print custom text at the end of your help output.
        # (similar to how Rails does it)
        # shell.say 'All commands can be run with -h (or --help) for more information.'
      end

      def start(given_args = ARGV, config = {})
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
    end


  end


end


module MyModule

end
#
# module Gena
#   # class Gena::Plugin
#
#   # class Plugin < Application
#   #
#   # end
#
#   # class Module < Thor
#
#     def self.included(thor)
#       thor.class_eval do
#
#
#
#
#       end
#     # end
#
#
#
#   end
#
# end




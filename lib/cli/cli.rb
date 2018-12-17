require 'thor'

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

      def plugin_classes
        class_for_command.values.uniq
      end

      # Override help to forward

      def help(shell, subcommand = false)

        #List plugin commands separately from Gena general commands
        plugins = []
        class_for_command.each do |command, klass|
          plugins += klass.printable_commands(false)
        end

        plugins.uniq!

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


      # Override start to do custom dispatch (looking for plugin for unknown command)

      def start(given_args = ARGV, config = {})

        config[:shell] ||= Thor::Base.shell.new

        command_name = normalize_command_name(retrieve_command_name(given_args.dup))
        clazz = command_name ? class_for_command[command_name] : nil

        if command_name && clazz
          if check_dependencies(command_name, clazz.dependencies)
            clazz.dispatch(nil, given_args.dup, nil, config)
          end
        else
          dispatch(nil, given_args.dup, nil, config)
        end

        finish

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

      def finish
        XcodeUtils.shared.save_project
        Application.new.check_gena_version
      end


    end

    no_tasks do


      def check_gena_version
        # Read cache
        say "Checking for update.." if $verbose

        version_path = File.expand_path "#{GENA_HOME}/version.plist"
        plist = File.exists?(version_path) ? Plist::parse_xml(version_path) : Hash.new

        data = nil

        if !plist['timestamp'] || (DateTime.now.to_time.to_i - plist['timestamp'].to_i) > GENA_UPDATE_CHECK_INTERVAL
          last_release_text = `curl https://api.github.com/repos/alexgarbarev/gena/releases/latest -s`
          data = JSON.parse(last_release_text)

          plist['data'] = data
          plist['timestamp'] = DateTime.now.to_time.to_i
          File.open(version_path, 'w') { |f| f.write plist.to_plist }
        else
          data = plist['data']
        end

        tag_name = data['tag_name']

        if tag_name > VERSION
          say "New update v#{tag_name} is available for gena.\nSee release notes: #{data['url']}", Color::YELLOW
          if data['body'].length > 0
            say "---------------------\n#{data['body']}\n---------------------", Color::YELLOW
          end
          say "Please update by:\n#{set_color('gem install gena', Color::GREEN)}", Color::YELLOW
        end

      end

      def self.check_dependencies(plugin_name, dependencies)

        missing_gems = {}

        dependencies.each do |gem_name, version|
          begin
            require gem_name
          rescue LoadError
            missing_gems[gem_name] = version
          end
        end

        if missing_gems.count > 0
          puts "The following gems required for #{plugin_name.yellow}:\n\t#{missing_gems.keys.join(', ')}"
          puts "Would you like to install them? (Yn)"
          answer = STDIN.gets.chomp
          if answer == 'Y' || answer == 'y' || answer == '' || answer == 'yes'
            gems = missing_gems.collect { |k, v| "#{k}:#{v}" }
            command = "gem install #{gems.join(" ")}"
            puts command
            result = system(command)
            if result
              puts "All dependencies installed successfully! Run your command again.".green
            else
              puts "Error occured while installing dependencies. Please install them manually and try again.".red
            end
            return false
          else
            puts "Unable to run #{plugin_name}. Please install dependencies and try again.".red
            return false
          end
        else
          return true
        end
      end

    end

  end

end





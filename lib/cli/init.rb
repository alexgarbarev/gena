module Gena

  class Application < Thor

    desc 'reconfigure [COMMAND]', 'Restores default parameters for plugin inside gena.plist'
    def reconfigure(command)

      $config = Gena::Config.new
      $config.load_plist_config

      data = $config.data[GENA_PLUGINS_CONFIG_KEY] || Hash.new

      Application.plugin_classes.each do |klass|

        plugin_config_name = klass.plugin_config_name
        if plugin_config_name == command
          say "Setting defaults for '#{command}'..", Color::GREEN
          data[plugin_config_name] = klass.plugin_config_defaults
          $config.data[GENA_PLUGINS_CONFIG_KEY] = data
          $config.save!
          return
        end
      end
      say "Can't find plugin with name '#{command}'", Color::RED
    end

    desc 'init', 'Initialize gena.plist with default parameters'
    def init

      xcode_project_name = `find . -name *.xcodeproj`
      xcode_project_name.strip!

      xcode_project_name = ask_with_default("Enter path for #{set_color('project', Color::YELLOW)} or ENTER to continue (#{xcode_project_name}):", xcode_project_name)

      xcode_project = Xcodeproj::Project.open(xcode_project_name)


      main_target = nil
      test_target = nil
      xcode_project.native_targets.each do |target|
        if target.product_type == 'com.apple.product-type.application'
          main_target = target
        elsif target.product_type == 'com.apple.product-type.bundle.unit-test'
          test_target = target
        end
      end

      hash = Hash.new
      hash[:plugins_url] = [
          'https://github.com/alexgarbarev/gena-plugins.git'
      ]

      unless main_target
        say "Can't find application target in your Xcode project. Please create application target and try again", Color::RED
        abort
      end

      default_build_configuration = main_target.build_configuration_list.default_configuration_name || 'Debug'
      info_plist_value = main_target.build_configuration_list.get_setting('INFOPLIST_FILE')[default_build_configuration]
      if info_plist_value['$(SRCROOT)/']
        info_plist_value['$(SRCROOT)/'] = ''
      end

      hash['company'] = xcode_project.root_object.attributes['ORGANIZATIONNAME'].to_s
      hash['prefix'] = xcode_project.root_object.attributes['CLASSPREFIX'].to_s
      hash['project_name'] = xcode_project.root_object.name
      hash['info_plist'] = info_plist_value

      if main_target
        sources_path = common_path_in_target(main_target, 'main.m')
        sources_path = relative_to_current_dir(sources_path)

        hash['project_target'] = main_target.name
        hash['sources_dir'] = ask_with_default("Enter path for #{set_color('sources', Color::YELLOW)} or ENTER to continue (#{sources_path}):", sources_path)
     end

      if test_target
        tests_path = common_path_in_target(test_target, "#{sources_path}/")
        tests_path = relative_to_current_dir(tests_path)

        hash['test_target'] = test_target.name
        hash['tests_dir'] = ask_with_default("Enter path for #{set_color('tests', Color::YELLOW)} or ENTER to continue (#{tests_path}):", tests_path)
      else
        say "Can't find target for UnitTests. You setup it later using 'test_target' and 'tests_dir' key (similar to sources)", Color::YELLOW
        hash['test_target'] = ''
        hash['tests_dir'] = ''
      end

      language = file_exists_in_target?(main_target, 'main.m') ? "objc" : "swift"
      hash['language'] = ask_with_default("Enter main #{set_color('language', Color::YELLOW)} or ENTER to continue (#{language}):", language)

      say '===============================================================', Color::YELLOW
      print_table(hash)
      say '===============================================================', Color::YELLOW

      File.open('gena.plist', 'w') { |f| f.write hash.to_plist }


      say "'gena.plist' created..", Color::GREEN
    end

    no_tasks do

      @downloaded_urls = Hash.new


      def check

        $verbose = (ARGV.include? '-v')
        if $verbose
          ARGV.reject! { |n| n == '-v' || n == '--verbose' }
        end

        unless Config.exists?
          if ARGV == ['init']
            init
            ARGV.replace([])
          else
            unless no? "'gena.plist' is not exists. Do you want to create new one? (Y/n)", Color::YELLOW
              init
            end
          end
        end

        $config = Gena::Config.new
        $config.load_plist_config

        unless $config.data
          say '\'gena.plist\' is corrupted! Try recreating', Color::RED
          abort
        end

        if !$config.data['plugins_url'] || $config.data['plugins_url'].count == 0
          say "'plugins_url' key is missing inside 'gena.plist'", Color::RED
          abort
        end
        download_plugins
        load_plugins
        save_plugin_configs
      end

      def download_plugins
        load_downloaded_urls
        $config.data['plugins_url'].each do |plugin_url|
          if remote_url? plugin_url
            is_old = old_url?(plugin_url)
            if !downloaded_url?(plugin_url) || is_old
              message = is_old ? 'not up to date' : 'not downloaded yet'
              say "Plugin at '#{plugin_url}' #{message}", Color::YELLOW
              download_plugin_at plugin_url
            end
          end
        end
        save_downloaded_urls
      end

      def remote_url?(url)
        url =~ /(.+@)*([\w\d\.]+):(.*)/
      end

      def downloaded_url?(url)
        File.exists? File.expand_path(download_path_for(url))
      end

      def old_url?(url)
        entity = @downloaded_urls[key_for_url(url)]
        return true unless entity
        elapsed_seconds = DateTime.now.to_time.to_i - entity['timestamp'].to_i
        if elapsed_seconds > GENA_UPDATE_CHECK_INTERVAL
          current_hash = `git ls-remote #{url} refs/heads/master | cut -f 1`.strip
          entity['timestamp'] = DateTime.now.to_time.to_i
          return current_hash != entity['hash']
        end
        false
      end

      def load_downloaded_urls
        plist_path = File.expand_path "#{GENA_HOME}/plugins.plist"
        if File.exists? plist_path
          @downloaded_urls = Plist::parse_xml(plist_path)
        else
          @downloaded_urls = Hash.new
        end
      end

      def save_downloaded_urls
        File.open(File.expand_path("#{GENA_HOME}/plugins.plist"), 'w') { |f| f.write @downloaded_urls.to_plist }
      end

      def key_for_url(url)
        Digest::MD5.hexdigest url
      end

      def download_path_for(url)
        hash = Digest::MD5.hexdigest url
        File.expand_path "#{GENA_HOME}/plugins/#{hash}"
      end

      def download_plugin_at(url)
        say "Downloading plugin from '#{url}'..", Color::GREEN, ' '
        output_path = File.expand_path(download_path_for(url))
        FileUtils.rmtree output_path
        FileUtils.mkdir_p output_path
        result = gena_system "git clone --depth 1 #{url} #{output_path}"
        if result
          say 'success!', Color::GREEN
          @downloaded_urls[key_for_url(url)] = {
              'hash' => `git ls-remote #{url} refs/heads/master | cut -f 1`.strip,
              'timestamp' => DateTime.now.to_time.to_i
          }

        else
          say 'Failed! Run with \'-v\' to debug', Color::RED
        end
      end

      def load_plugins
        registered = []
        $config.data['plugins_url'].each do |plugin_url|
          path = remote_url?(plugin_url) ? download_path_for(plugin_url) : plugin_url
          Dir["#{File.expand_path(path)}/**/*.rb"].each do |file|
            template_name = file.split(File::SEPARATOR)[-2]
            unless registered.include? template_name
              registered << template_name
              say "Loading '#{file}'..", Color::YELLOW if $verbose
              require file
            end
          end
        end
        Gena::Plugin.descendants.each do |clazz|
          clazz.setup_thor_commands
        end
      end

      def save_plugin_configs

        data = $config.data[GENA_PLUGINS_CONFIG_KEY] || Hash.new

        Application.plugin_classes.each do |klass|

          defaults = klass.plugin_config_defaults

          if defaults.count > 0
            plugin_config_name = klass.plugin_config_name

            if !data[plugin_config_name] || data[plugin_config_name].count == 0
              say "Writing config defaults for plugin '#{plugin_config_name}'..", Color::GREEN
              data[plugin_config_name] = defaults
            elsif !data[plugin_config_name].keys.to_set.eql? defaults.keys.to_set
              missing_keys = defaults.keys - data[plugin_config_name].keys
              if missing_keys.count > 0
                say "Adding missing config keys #{missing_keys} for plugin '#{plugin_config_name}.'", Color::GREEN
                missing_keys.each { |key| data[plugin_config_name][key] = defaults[key] }
              end
            end
          end

        end

        $config.data[GENA_PLUGINS_CONFIG_KEY] = data
        $config.save!

      end

      private

      def ask_with_default(message, default)
        value = ask(message)
        if value.empty?
          value = default
        end
        value
      end

      def relative_to_current_dir(path)

        if path.empty? || !path["#{Dir.pwd}/"]
          path
        else
          result = path.dup
          result["#{Dir.pwd}/"] = ''
          result
        end
      end

      def common_path_in_target(target, except_match)
        common = ''
        target.source_build_phase.files.each do |file|
          unless file.file_ref.real_path.to_s[except_match]
            path_components = file.file_ref.real_path.to_s #.split('/')
            if common.empty?
              common = path_components
            else
              common = common.path_intersection path_components
            end
          end
        end

        if File.file? common
          common = common.delete_last_path_component
        end
        if common[-1] == '/'
          common = common[0..-2]
        end
        common
      end

      def file_exists_in_target?(target, file_name)
        target.source_build_phase.files.each do |file|
          if File.basename(file.file_ref.real_path.to_s) == file_name
            return true
          end
        end
        false
      end

    end

  end


end
require 'plist'
require 'yaml'
require 'generamba'
require 'digest'

module Gena

  class Application < Thor

    desc 'init', 'Initialize gena.plist with default parameters'

    def init
      if yes? "'gena.plist' is not exists. Do you want to create new one? (Y/n)", Color::YELLOW
        Config.create
        say "'gena.plist' created..", Color::GREEN
      end

    end

    no_tasks do
      def check

        $verbose = (ARGV.include? '-v')
        if $verbose
          ARGV.reject! { |n| n == '-v' || n == '--verbose' }
        end

        unless Config.exists?
          init
        end

        $config = Gena::Config.new
        $config.load_plist_config

        if $config.data['plugins_url'].count == 0
          say "'plugins_url' key is missing inside 'gena.plist'", Color::RED
          abort
        end
        download_plugins
        load_plugins
      end

      def download_plugins
        $config.data['plugins_url'].each do |plugin_url|
          if remote_url? plugin_url
            unless downloaded_url? plugin_url
              say "Plugin at '#{plugin_url}' not downloaded yet", Color::YELLOW
              download_plugin_at plugin_url
            end
          end
        end
      end

      def remote_url?(url)
        url =~ /(.+@)*([\w\d\.]+):(.*)/
      end

      def downloaded_url?(url)
        File.exists? File.expand_path(download_path_for(url))
      end

      def download_path_for(url)
        hash = Digest::MD5.hexdigest url
        "#{GENA_HOME}/plugins/#{hash}"
      end

      def download_plugin_at(url)
        say "Downloading plugin from '#{url}'..", Color::GREEN, ' '
        FileUtils.mkdir_p File.expand_path(download_path_for(url))
        result = gena_system "git clone --depth 1 #{url} #{download_path_for(url)}"
        if result
          say 'success!', Color::GREEN
        else
          say 'Failed! Run with \'-v\' to debug', Color::RED
        end
      end

      def load_plugins
        registered = []
        $config.data['plugins_url'].each do |plugin_url|
          path = remote_url?(plugin_url) ?  download_path_for(plugin_url) : plugin_url
          Dir["#{File.expand_path(path)}/**/*.rb"].each do |file|
            template_name = file.split(File::SEPARATOR)[-2]
            unless registered.include? template_name
              registered << template_name
              say "Loading '#{file}'..", Color::YELLOW if $verbose
              require file
            end
          end
        end
        puts "Registered: #{registered}" if $verbose
      end


    end


  end


  class Config

    @data = {}

    def Config.exists?
      File.exists?('gena.plist')
    end

    def Config.create

      hash = Hash.new
      hash[:plugins_url] = [
          '~/Development/gena-templates',
          'git@github.com:Loud-Clear/gena-templates.git'
      ]

      File.open('gena.plist', 'w') { |f| f.write hash.to_plist }
    end


    def load_plist_config()

      if File.exists?('generate.plist')
        puts 'Found old generate.plist. Renaming to gena.plist'
        FileUtils.mv('generate.plist', 'gena.plist')
      end

      @data = Plist::parse_xml('gena.plist')
    end

    def to_rambafile()
      rambafile_content = {}
      rambafile_content['project_name'] = @config['project_name']
      rambafile_content['xcodeproj_path'] = "#{@config['project_name']}.xcodeproj"
      rambafile_content['company'] = @config['company']
      rambafile_content['prefix'] = @config['prefix']
      rambafile_content['project_target'] = @config['project_target']
      rambafile_content['test_target'] = @config['test_target']
      rambafile_content['templates'] = [{name: 'default'}]
      rambafile_content.to_yaml
    end

    def data()
      @data
    end

    def xcode_project_path()
      "#{@data['project_name']}.xcodeproj"
    end

  end

end
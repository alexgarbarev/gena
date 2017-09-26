
require 'plist'
require 'yaml'
require 'generamba'

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
        unless Config.exists?
          init
        end
      end
    end


  end


  class Config

    @config = {}

    def Config.exists?
      File.exists?('gena.plist')
    end

    def Config.create

      hash = Hash.new
      hash[:plugins_url] = [
          '~/Development/gena-templates',
          'git@github.com:Loud-Clear/gena-templates.git'
      ]

      File.open("gena.plist", 'w') {|f| f.write hash.to_plist }
    end


    def load_plist_config()

      if File.exists?('generate.plist')
        puts 'Found old generate.plist. Renaming to gena.plist'
        FileUtils.mv('generate.plist', 'gena.plist')
      end

      @config = Plist::parse_xml('gena.plist')
    end

    def to_rambafile()
      rambafile_content = {}
      rambafile_content['project_name'] = @config['project_name']
      rambafile_content['xcodeproj_path'] = "#{@config['project_name']}.xcodeproj"
      rambafile_content['company'] = @config['company']
      rambafile_content['prefix'] = @config['prefix']
      rambafile_content['project_target'] = @config['project_target']
      rambafile_content['test_target'] = @config['test_target']
      rambafile_content['templates'] = [ { name: 'default'}]
      rambafile_content.to_yaml
    end

    def config()
      @config
    end

    def xcode_project_path()
      "#{@config['project_name']}.xcodeproj"
    end

  end

end
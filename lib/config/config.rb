
require 'plist'
require 'yaml'
require 'generamba'

module Gena

  class Config

    @config = {}

    def Config.exists?
      File.exists?('gena.plist')
    end

    def Config.create_if_needed

      unless Config.exists?
        puts "gena.plist is not exists. Do you want to create one?"
        result = gets.chomp
        puts "r = #{result}"
        # exit_with_message 'Gena.plist is not exists'
      end


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
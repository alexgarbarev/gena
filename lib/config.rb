
require 'plist'
require 'yaml'
require 'generamba'

module Generate

  class Config

    @config = {}

    def load_plist_config()
      @config = Plist::parse_xml('generate.plist')
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
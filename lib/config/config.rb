require 'plist'
require 'yaml'
require 'digest'

module Gena

  class Config

    @data = {}

    def Config.exists?
      File.exists?('gena.plist')
    end

    def Config.create
      hash = Hash.new
      hash[:plugins_url] = [
          '~/Development/gena-plugins'
      ]
      hash['sources_dir'] = '/Users/alex/Development/fisho-ios/Sources'

      File.open('gena.plist', 'w') { |f| f.write hash.to_plist }
    end

    def save!
      File.open('gena.plist', 'w') { |f| f.write self.data.to_plist }
    end

    def load_plist_config
      @data = Plist::parse_xml('gena.plist')
    end

    def data
      @data
    end

    def data=(new_data)
      @data = new_data
    end

    def data_without_plugins
      @data.reject { |k, v| k == GENA_PLUGINS_CONFIG_KEY }
    end

    def header_dir
      if @data['header'] && !@data['header'].empty?
        expand_to_project(File.dirname(@data['header']))
      else
        ''
      end
    end

    def project_dir
      File.expand_path(self.data['project_dir'].empty? ? '.' : self.data['project_dir'])
    end

    def expand_to_project(path)
      if path[0] == '/'
        path
      else
        File.join(self.project_dir, path)
      end
    end

    def collapse_to_project(path)
      if path[0] == '/'
        path = path.dup
        path["#{$config.project_dir}/"] = ''
      end
      path
    end

    def sources_dir
      self.expand_to_project(self.data['sources_dir'])
    end

    def tests_dir
      self.expand_to_project(self.data['tests_dir'])
    end

    def xcode_project_path
      path = self.expand_to_project("#{@data['project_name']}.xcodeproj")
      unless File.exists? path
        say "Can't find project with name '#{@data['project_name']}.xcodeproj''", Color::RED
        abort
      end
      path
    end

  end

end
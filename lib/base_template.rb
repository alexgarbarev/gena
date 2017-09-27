module Gena

  class BaseTemplate

    def initialize(options, config)
      @options = options
      @config = config
    end

    def options
      @options
    end

    def config
      @config
    end

    def type_config
      @config['template_options'][self.class.template_name.downcase]
    end

    def self.template_name
      self.name.split('::').last || ''
    end

    def sources_absolute_path
      "#{@config['sources_dir']}/#{sources_path}"
    end

    def tests_absolute_path
      "#{@config['tests_dir']}/#{tests_path}"
    end

    def template_parameters_string
      self.template_parameters.map{|k,v| "#{k}:#{v}"}.join(' ')
    end

    def self.descendants
      ObjectSpace.each_object(Class).select { |klass| klass < self }
    end

    def self.new_from_options(options, config)
      template_class = Object.const_get("Generate::#{options[:template_type].capitalize_first}")
      template_class.new(options, config.data)
    end

    def self.name_required?(options)
      template_class = Object.const_get("Generate::#{options[:template_type].capitalize_first}")
      template_class.generamba?
    end

    ##############
    #######     Methods to override in subclass
    ##############

    def self.register_options(opts, options)

    end

    def sources_path
      ''
    end

    def tests_path
      sources_path
    end

    def template_source_files
      []
    end

    def template_test_files
      []
    end

    # Custom parameters for generamba
    def template_parameters
      {  }
    end

    def self.generamba?
      true
    end

    def run

    end

  end

end

module Gena

  module Filetype
    class Context
      attr_accessor :target_key, :base_dir_key, :is_resource

      def initialize(target, base_dir, is_resource)
        @target_key = target
        @base_dir_key = base_dir
        @is_resource = is_resource
      end
    end
    SOURCE = Context.new('project_target', 'sources_dir', false)
    RESOURCE = Context.new('project_target', 'sources_dir', true)
    TEST_SOURCE = Context.new('test_target', 'tests_dir', false)
    TEST_RESOURCE = Context.new('test_target', 'tests_dir', true)
  end

  class Codegen < Thor

    no_tasks do


      def initialize(output_path, template_params)

        @output_path = output_path
        @template_params = template_params

      end


      def add_file(template_name, file_name, type, params = nil)

        # Getting path for template
        plugin_dir = File.dirname(caller.first.scan(/.*rb/).first)
        template_path = absolute_path_for_template(template_name, plugin_dir)

        # Output path
        output_path = absolute_path_for_output(file_name, type)

        # Params
        template_params = @template_params.merge($config.data_without_plugins)
        template_params = params.merge(template_params) if params
        template_params['date'] = Time.now.strftime('%d/%m/%Y')
        template_params['year'] = Time.new.year

        render_template_to_file(template_path, output_path, template_params)

        add_file_to_project(output_path, type)

      end

      def render_template(template_name, params)

        plugin_dir = File.dirname(caller.first.scan(/.*rb/).first)
        template_path = absolute_path_for_template(template_name, plugin_dir)

        render_template_from_path(template_path, params)

      end

      def render_template_to_file(template_name, output_path, params)

        plugin_dir = File.dirname(caller.first.scan(/.*rb/).first)
        template_path = absolute_path_for_template(template_name, plugin_dir)

        render_template_from_path_to_file(template_path, output_path, params)
      end

      def add_file_to_project(output_path, type)

        target_name = $config.data[type.target_key]

        target = XcodeUtils.shared.obtain_target(target_name)

        dirname = File.dirname(output_path)

        group = XcodeUtils.shared.make_group(dirname, dirname)

        XcodeUtils.shared.add_file(target, group, output_path, type.is_resource)
      end

      def remove_from_project(path)
        XcodeUtils.shared.delete_path(path)
      end

      private

      def setup_header_if_needed(params)
        unless Liquid::Template.file_system.is_a? GenaStaticHeader
          if $config.header_dir.empty?
            say "No 'header' field inside 'gena.plist'. You can specify path to header's liquid template there. Using default header", Color::YELLOW
            Liquid::Template.file_system = GenaStaticHeader.new(nil)
          else
            if File.exists? $config.header_dir
              header_content = IO.read($config.header_dir)
              header_template = Liquid::Template.parse(header_content)
              Liquid::Template.file_system = GenaStaticHeader.new(header_template.render(params))
            else
              say "Can't load header at path: #{$config.header_dir}. Using default header", Color::RED
              Liquid::Template.file_system = GenaStaticHeader.new(nil)
            end
          end
        end
      end


      def render_template_from_path(template_path, params)

        setup_header_if_needed(params)

        file_source = IO.read(template_path)
        template = Liquid::Template.parse(file_source)

        template.render(params)
      end

      def render_template_from_path_to_file(template_path, output_path, params)

        content = render_template(template_path, params)

        FileUtils.mkpath(File.dirname(output_path))

        say "Writing to file: #{output_path}", Color::GREEN
        File.open(output_path, 'w+') do |f|
          f.write(content)
        end
      end

      def absolute_path_for_output(file_name, type)
        # Output path
        base_dir = $config.expand_to_project($config.data[type.base_dir_key])

        if @output_path[0] == '/'
          puts 'Output path is absolute' if $verbose
          output_path = File.join(@output_path, file_name)
        else
          puts 'Output path is relative' if $verbose
          output_path = File.join(base_dir, @output_path, file_name)
        end
        output_path
      end

      def absolute_path_for_template(template_path, plugin_dir)
        result = ''

        expanded = File.expand_path(template_path)
        if File.exists? expanded
          result = expanded
        else
          joined = File.join(plugin_dir, template_path)
          if File.exists? joined
            result = joined
          end
        end

        if !result.empty?
          say "Found template at path '#{result}'", Color::YELLOW if $verbose
        else
          say "Can't find path for template '#{template_path}'", Color::RED
          abort
        end
        result
      end

    end

  end

  class GenaStaticHeader < Liquid::BlankFileSystem

    def initialize(text)
      @text = text
    end

    def read_template_file(name)

      if name == 'header'
        @text || '////////////////////////////////////////////////////////////////////////////////
//
//  Generated by Gena.
//
////////////////////////////////////////////////////////////////////////////////'
      else
        ''
      end
    end

  end

end
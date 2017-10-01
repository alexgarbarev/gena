require 'liquid'

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


      def add_file(template_name, file_name, type)

        say "Adding file from template #{template_name}", Color::YELLOW

        # Getting path for template
        plugin_dir = caller.first.scan(/.*rb/).first.delete_last_path_component
        template_path = absolute_path_for_template(template_name, plugin_dir)

        # Output path
        output_path = absolute_path_for_output(file_name, type)



        file_source = IO.read(template_path)
        # Liquid::Template.file_system = Liquid::LocalFileSystem.new(template.template_path.join('snippets'), '%s.liquid')

        template = Liquid::Template.parse(file_source)


        puts "Template params: #{@template_params}"

        content = template.render(@template_params)

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
          say "Found template at path '#{result}'", Color::YELLOW
        else
          say "Can't find path for template '#{template_path}'", Color::RED
          abort
        end
        result
      end

    end

  end

end
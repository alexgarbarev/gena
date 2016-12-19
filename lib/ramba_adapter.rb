
require_relative 'config'

class RambaAdapter

  RAMBAFILE_NAME = 'Rambafile'
  RAMBA_TEMPLATES_FOLDER = 'Templates'

  @template
  @config

  def initialize(template, config)
    @template = template
    @config = config
  end

  def create_rambafile
    File.open("./#{RAMBAFILE_NAME}", 'w') {|f| f.write @config.to_rambafile }
  end

  def delete_rambafile
    FileUtils.rm("./#{RAMBAFILE_NAME}")
  end

  def regenerate_default_template
    delete_default_template
    create_default_template
  end

  def delete_default_template
    FileUtils.rm_rf "#{RAMBA_TEMPLATES_FOLDER}/default"
  end

  def create_default_template
    #Create folders
    dst_dir = "#{RAMBA_TEMPLATES_FOLDER}/default"
    FileUtils.mkdir_p dst_dir
    type_dir = template_directory(@template)

    #Copy files..
    copy_if_needed "#{type_dir}/Code", "#{dst_dir}/Code"
    copy_if_needed "#{type_dir}/Tests", "#{dst_dir}/Tests"
    copy_if_needed "#{type_dir}/snippets", "#{dst_dir}/snippets"

    #Generate rambaspec
    generate_rambaspec("#{dst_dir}/default.rambaspec", @template.options)
  end

  def generate_rambaspec(output, options)
    rambaspec = {}

    rambaspec['name'] = 'default'
    rambaspec['summary'] = "Template generated from #{@template} template class"
    rambaspec['author'] = 'generate.rb'
    rambaspec['version'] = '1.0.0'
    rambaspec['license'] = 'MIT'

    rambaspec['code_files'] = @template.template_source_files
    rambaspec['test_files'] = @template.template_test_files  if options[:generate_tests]

    File.open(output, 'w') {|f| f.write rambaspec.to_yaml( :UseFold => true) }
  end

  def template_directory(template)
    "#{TEMPLATES_FOLDER}/#{template.class.template_name}"
  end

  def copy_if_needed(src, dst)
    FileUtils.cp_r src, dst if File.exists? src
    puts "copied #{src} #{dst} (#{File.exists? src})"
  end

  def generamba_gen_command(options)
    sources_path = @template.sources_absolute_path
    test_path = @template.tests_absolute_path
    custom_params = @template.template_parameters_string

    cli_command = "generamba gen #{options[:name]} default"

    if sources_path.length > 0
      cli_command << " --module_path #{sources_path}"
    end

    if test_path.length > 0
      cli_command << " --test_path #{test_path}"
    end

    if custom_params.length > 0
      cli_command << " --custom_parameters #{custom_params}"
    end

    cli_command
  end

end
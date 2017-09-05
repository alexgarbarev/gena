require 'optparse'
require_relative '../base_template'

class GenaCli

  def all_types
    Generate::BaseTemplate.descendants.map { |clazz| clazz.template_name.downcase }.join(', ')
  end


  def parse_arguments
    options = {}

    parser = OptionParser.new do |opts|
      opts.banner = "Usage: gena TEMPLATE MODULE_NAME [options]"
      opts.separator ""
      opts.separator "TEMPLATE is be one of [#{all_types}]"
      opts.separator ""
      opts.separator "Options are:"

      Generate::BaseTemplate.descendants.each do |clazz|
        clazz.register_options(opts, options)
      end
      opts.on('-h', '--help', 'Prints help') { puts opts; exit }
      opts.on('-v', '--verbose') { options[:verbose] = true }
      opts.on('--tests', 'Generate tests if possible') {  options[:generate_tests] = true }
      opts.on('--cleanup', 'Removes temporary data instead of generation') { options[:cleanup] = true; return options; }
      opts.on('--fetch', 'Fetches templates from remote repository') { options[:fetch] = true; return options; }
    end

    parser.parse!

    type = ARGV[0]
    unless type
      puts "\n- You should specify TEMPLATE to proceed\n\n----\n\n"
      puts parser
      exit
    end
    ARGV.delete_at(0)
    options[:template_type] = type

    name = ARGV.pop

    name_required = Generate::BaseTemplate.name_required?(options)

    if !name && name_required
      puts "\n- You should specify MODULE_NAME to proceed with #{type} template\n\n----\n\n"
      puts parser
      exit
    end

    if name
      name = name.capitalize_first
      options[:name] = name
    end

    options
  end

end
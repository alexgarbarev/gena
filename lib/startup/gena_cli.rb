require 'optparse'
require_relative '../base_template'
require_relative '../utils/system_utils'

class GenaCli

  def all_types
    Generate::BaseTemplate.descendants.map { |clazz| clazz.template_name.downcase }.join(', ')
  end


  def initialize

    @parser = OptionParser.new do |opts|
      opts.banner = "Usage: gena PLUGIN [options]"
      opts.separator ""
      opts.separator "PLUGIN is be one of [#{all_types}]"
      opts.separator ""
      opts.separator "General options are:"

      # Generate::BaseTemplate.descendants.each do |clazz|
      #   clazz.register_options(opts, options)
      # end
      opts.on('-h', '--help', 'Prints this help') { puts opts; exit }
      opts.on('-v', '--verbose') { options[:verbose] = true }
      # opts.on('--tests', 'Generate tests if possible') {  options[:generate_tests] = true }
      # opts.on('--cleanup', 'Removes temporary data instead of generation') { options[:cleanup] = true; return options; }
      opts.on('--fetch', 'Fetches templates from remote repository') { options[:fetch] = true; return options; }
    end
  end

  def print_help
    puts @parser
  end

  def parse_arguments
    options = {}

    @parser.parse!

    type = ARGV[0]
    unless type
      exit_with_message 'You should specify PLUGIN to proceed'
    end
    ARGV.delete_at(0)
    options[:template_type] = type

    name = ARGV.pop

    name_required = Generate::BaseTemplate.name_required?(options)

    if !name && name_required
      exit_with_message "You should specify MODULE_NAME to proceed with #{type} template"
    end

    if name
      name = name.capitalize_first
      options[:name] = name
    end

    options
  end

end

require_relative '../gena'

def exit_with_message(message, show_help = true)

  puts "\n- #{message}\n\n----\n\n"

  if show_help
    cli = Gena::Cli.new
    cli.print_help
  end

  if $running_tests
    raise message
  else
    exit 1
  end
end
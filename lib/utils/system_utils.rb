
require_relative '../gena'

def exit_with_message(message)

  puts "\n- #{message}\n\n----\n\n"

  cli = GenaCli.new
  cli.print_help

  if $running_tests
    raise message
  else
    exit 1
  end



end
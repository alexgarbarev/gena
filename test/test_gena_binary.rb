
require 'minitest/autorun'

require 'gena'


class GenaTests < Minitest::Test

  def test_hello

    cli = GenaCli.new

    ARGV.replace ["--fetch"]

    cli.parse_arguments

    assert_equal "hello world", "hello world"
  end

  def test_system_plugins

    loader = PluginsLoader.new

    puts "\"#{loader.load_all_plugins}\""
  end

end
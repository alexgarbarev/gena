
require 'minitest/autorun'

require_relative '../lib/gena'

$running_tests = true


class GenaCliTests < Minitest::Test

  def test_empty_call_returns_help
    cli = Gena::Cli.new
    exception = assert_raises RuntimeError do
      cli.parse_arguments
    end
    assert_equal(exception.message, 'You should specify PLUGIN to proceed')
  end

  def test_setup_begin_without_gena_plist

    if File.exists? 'gena.plist'
      FileUtils.remove 'gena.plist'
    end

    # cli = GenaCli.new


  end

end

class PluginsLoaderTests < Minitest::Test

  def test_plugin_loader

    loader = PluginsLoader.new

    puts "#{loader.load_all_plugins}"

  end

end


class GenaTests < Minitest::Test

  def test_hello

    # cli = GenaCli.new
    #
    # ARGV.replace ["--fetch"]
    #
    # cli.parse_arguments
    #
    # assert_equal "hello world", "hello world"
  end


end
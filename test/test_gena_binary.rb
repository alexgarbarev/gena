
require 'minitest/autorun'

require 'gena'


class GenaTests < Minitest::Test

  def test_hello

    cli = GenaCli.new

    cli.parse_arguments

    assert_equal "hello world", "hello world"
  end

end
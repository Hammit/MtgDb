require 'minitest_helper'

class TestMtgDb < MiniTest::Unit::TestCase
  def test_that_it_has_a_version_number
    refute_nil ::MtgDb::VERSION
  end

  def test_it_does_something_useful
    assert false
  end
end

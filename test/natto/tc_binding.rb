# coding: utf-8

# TestNatto encapsulates tests for the basic
# behavior of the Natto::Binding module.
class TestNattoBinding < Test::Unit::TestCase
  def setup
    @klass = Class.new do
      include Natto::Binding
    end
  end

  def teardown
    @klass = nil
  end

  # Tests the mecab_version function.
  def test_mecab_version
    assert_equal('0.98', @klass.mecab_version)
  end

  # Tests for the inclusion of mecab methods made available
  # to any classes including the Natto::Binding module.
  def test_functions_included
    [  :mecab_version, 
       :mecab_new2, 
       :mecab_destroy, 
       :mecab_sparse_tostr, 
       :mecab_strerror,
       :mecab_dictionary_info ].each do |f|
       assert(@klass.respond_to? f)
    end
  end
end
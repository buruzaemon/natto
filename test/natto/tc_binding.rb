# coding: utf-8

class TestNattoBinding < MiniTest::Unit::TestCase
  def setup
    @ver = `mecab -v`.strip.split.last
    @klass = Class.new do
      include Natto::Binding
    end
  end

  def teardown
    @ver, @klass = nil,nil
  end

  def test_fu
    refute_nil @klass
  end

  def test_mecab_version
    assert_equal(@ver, @klass.mecab_version)
  end

  def test_functions_included
    [  :mecab_new2, 
       :mecab_version, 
       :mecab_strerror,
       :mecab_destroy, 
       :mecab_set_theta,
       :mecab_set_lattice_level,
       :mecab_set_all_morphs,
       :mecab_sparse_tostr, 
       :mecab_sparse_tonode,
       :mecab_nbest_init,
       :mecab_nbest_sparse_tostr, 
       :mecab_nbest_next_tonode,
       :mecab_format_node,
       :mecab_dictionary_info 
    ].each do |f|
      assert(@klass.respond_to? f)
    end
  end
end

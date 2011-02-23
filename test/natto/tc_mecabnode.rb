# coding: utf-8
require 'rbconfig'
require 'nkf'

# TestMeCabNode encapsulates tests for the basic
# behavior of Natto::MeCabNode
class TestMeCabNode < Test::Unit::TestCase
  
  TEST_STR = '試験ですよ、これが。'
  @host_os = RbConfig::CONFIG['host_os']
  if @host_os =~ /mswin|mingw/i and TEST_STR.respond_to?(:encoding)
    TEST_STR = NKF.nkf("-Ws", TEST_STR)
  end

  def setup
    nm = Natto::MeCab.new
    @nodes = []
    nm.parse(TEST_STR) { |n| @nodes << n }
  end

  def teardown
    @nodes = nil
  end

  # Tests the surface and feature accessors methods.
  def test_surface_and_feature_accessors
    raw = `echo #{TEST_STR} | mecab`.lines.to_a
    raw.pop
    expected = {}
    raw.each do |l|
      tokens = l.split("\t")
      expected[tokens[0]]=tokens[1].strip
    end

    actual = {}
    @nodes.pop
    @nodes.each do |n|
      k = n.surface
      v = n.feature
      puts "---> #{k} = #{v}"
      actual[k]=v
    end
   puts actual 
    assert_equal(expected, actual)
  end

  # Tests that the accessors of Natto::MeCabNode exist.
  # Note: Object#id is deprecated in 1.9.n, but comes with a warning
  #       in 1.8.n
  def test_mecabnode_accessors
    node = @nodes[0]
    members = [
      :prev,
      :next,
      :enext,
      :bnext,
      :rpath,
      :lpath,
      :begin_node_list,
      :end_node_list,
      :surface,
      :feature,
      :id,
      :length,
      :rlength,
      :rcAttr,
      :lcAttr,
      :posid,
      :char_type,
      :stat,
      :isbest,
      :sentence_length,
      :alpha,
      :beta,
      :prob,
      :wcost,
      :cost,
      :token
    ]
    members.each do |nomme|
      assert_not_nil(node.respond_to? nomme ) 
    end
    
    # NoMethodError will be raised for anything else!
    assert_raise NoMethodError do
      node.send :unknown_attr
    end
  end
end

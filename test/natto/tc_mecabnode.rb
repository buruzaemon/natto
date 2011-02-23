# coding: utf-8
require 'rbconfig'
require 'nkf'

# TestMeCabNode encapsulates tests for the basic
# behavior of Natto::MeCabNode
class TestMeCabNode < Test::Unit::TestCase
  
  host_os = RbConfig::CONFIG['host_os']
  # we need to transfrom from UTF-8 ot SJIS if we are on Windows!
  if host_os =~ /mswin|mingw/i
    TEST_STR = NKF.nkf("-Ws", '試験ですよ、これが。')
  else
    TEST_STR = '試験ですよ、これが。'
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
    raw.delete_if {|e| e =~ /^(EOS|BOS|\t)/ }
    expected = {}
    raw.each do |l|
      tokens = l.split("\t")
      expected[tokens[0]]=tokens[1].strip
    end

    actual = {}
   # @nodes.delete_if {|e| e =~ /^(EOS|BOS|\t)/ }
    @nodes.each do |n|
      actual[n.surface]=n.feature if (n.stat==Natto::MeCabNode::NOR_NODE || 
                                      n.stat==Natto::MeCabNode::UNK_NODE)
    end
    
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

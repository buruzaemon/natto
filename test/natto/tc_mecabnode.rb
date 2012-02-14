# coding: utf-8
require 'rbconfig'

# TestMeCabNode encapsulates tests for the basic
# behavior of Natto::MeCabNode
class TestMeCabNode < Test::Unit::TestCase

  def setup
    @host_os = RbConfig::CONFIG['host_os']
    @arch    = RbConfig::CONFIG['arch']

    if @host_os =~ /mswin|mingw/i
      @test_cmd = 'type "test\\natto\\test_sjis"'
    else
      @test_cmd = 'cat "test/natto/test_utf8"'
    end

    nm = Natto::MeCab.new
    @nodes = []
    nm.parse(`#{@test_cmd}`) { |n| @nodes << n }
  end

  def teardown
    @nodes, @host_os, @arch, @test_cmd = nil,nil,nil,nil
  end

  # Tests the surface and feature accessors methods.
  def test_surface_and_feature_accessors
    raw = `#{@test_cmd} | mecab`.lines.to_a
    raw.delete_if {|e| e =~ /^(EOS|BOS|\t)/ }
    raw.map!{|e| e.force_encoding(Encoding.default_external)} if @host_os =~ /mswin|mingw/i && @arch =~ /java/i && RUBY_VERSION.to_f >= 1.9
    expected = {}
    raw.each do |l|
      tokens = l.split("\t")
      expected[tokens[0]]=tokens[1].strip
    end

    actual = {}
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
    [ :prev,
      :next,
      :enext,
      :bnext,
      :rpath,
      :lpath,
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
      :alpha,
      :beta,
      :prob,
      :wcost,
      :cost 
    ].each do |nomme|
      assert_nothing_raised do
        node.send nomme
      end
    end
    
    # NoMethodError will be raised for anything else!
    assert_raise NoMethodError do
      node.send :unknown_attr
    end
  end
end

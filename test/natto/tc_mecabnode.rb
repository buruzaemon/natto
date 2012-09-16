# coding: utf-8
require 'rbconfig'

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
    
    nm = Natto::MeCab.new('-N2 -Oyomi')
    @nb_nodes = []
    nm.parse(`#{@test_cmd}`) { |n| @nb_nodes << n }
  end

  def teardown
    @nodes      = nil
    @nb_nodes   = nil
    @host_os    = nil
    @arch       = nil
    @test_cmd   = nil
  end

  def test_surface_and_feature_accessors
    raw = `#{@test_cmd} | mecab`.lines.to_a
    raw.delete_if {|e| e =~ /^(EOS|BOS|\t)/ }
    raw.map!{|e| e.force_encoding(Encoding.default_external)} if @arch =~ /java/i && RUBY_VERSION.to_f >= 1.9
    expected = {}
    raw.each do |l|
      tokens = l.split("\t")
      expected[tokens[0]]=tokens[1].strip
    end

    actual = {}
    @nodes.each do |n|
      actual[n.surface]=n.feature if (n.is_nor? || n.is_unk?)
    end
    
    assert_equal(expected, actual)
  end

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
    
    assert_raise NoMethodError do
      node.send :unknown_attr
    end
  end

  def test_is_eos
    assert(@nodes.pop.is_eos?)
    @nodes.each do |n|
      assert(n.is_nor?)
    end
  end

  def test_nbest_nodes
    n1 = @nb_nodes[0]
    n2 = @nb_nodes[8]
    assert_equal(n1.surface, n2.surface)
    assert_not_equal(n1.feature, n2.feature)
  end
end

# coding: utf-8
require 'rbconfig'

class TestMeCabNode < Minitest::Test
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
      actual[n.surface]=n.feature if n.surface and (n.is_nor? || n.is_unk?)
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
      refute_nil(node.send nomme)
    end
    
    assert_raises NoMethodError do
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
    refute_equal(n1.feature, n2.feature)
  end
end

# Copyright (c) 2015, Brooke M. Fujita.
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 
#  * Redistributions of source code must retain the above
#    copyright notice, this list of conditions and the
#    following disclaimer.
# 
#  * Redistributions in binary form must reproduce the above
#    copyright notice, this list of conditions and the
#    following disclaimer in the documentation and/or other
#    materials provided with the distribution.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
# ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

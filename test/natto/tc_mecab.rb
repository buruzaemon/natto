# coding: utf-8
require 'rbconfig'

class TestMeCab < MiniTest::Unit::TestCase
  def setup
    @m = Natto::MeCab.new()
    @m_f = Natto::MeCab.new '-F%pl\t%f[7]...' 
    @mn = Natto::MeCab.new '-N2' 
    @mn_f = Natto::MeCab.new '-N2 -F%pl\t%f[7]...' 
    @mn_w = Natto::MeCab.new '-N4 -Owakati' 
    @mn_y = Natto::MeCab.new '-N2 -Oyomi' 
    @e    = Natto::MeCab.new
    @e_f  = Natto::MeCab.new '-F%f[1]'
    @ver  = `mecab -v`.strip.split.last
    @host_os = RbConfig::CONFIG['host_os']
    @arch    = RbConfig::CONFIG['arch']
    
    if @host_os =~ /mswin|mingw/i
      @test_cmd = 'type "test\\natto\\test_sjis"'
      @br       = '\\n'
    else
      @test_cmd = 'cat "test/natto/test_utf8"'
      @br       = '\n'
    end
    @test_str = `#{@test_cmd}`
  end

  def teardown
    @m          = nil
    @m_f        = nil
    @mn         = nil
    @mn_f       = nil
    @mn_w       = nil
    @mn_y       = nil
    @ver        = nil
    @host_os    = nil
    @arch       = nil
    @test_cmd   = nil
    @test_str   = nil
  end
 
  def test_parse_mecab_options
    [ '-r /some/file',
      '-r/some/file',
      '--rcfile=/some/file',
      '--rcfile /some/file',
      {:rcfile=>"/some/file"} ].each do |opts|
      assert_equal({:rcfile => '/some/file'}, Natto::MeCab.parse_mecab_options(opts))
    end

    [ '-d /some/other/file',
      '-d/some/other/file',
      '--dicdir=/some/other/file',
      '--dicdir /some/other/file',
      {:dicdir=>"/some/other/file"} ].each do |opts|
      assert_equal({:dicdir => '/some/other/file'}, Natto::MeCab.parse_mecab_options(opts))
    end
   
    [ '-u /yet/another/file',
      '-u/yet/another/file',
      '--userdic=/yet/another/file',
      '--userdic /yet/another/file',
      {:userdic=>"/yet/another/file"} ].each do |opts|
      assert_equal({:userdic => '/yet/another/file'}, Natto::MeCab.parse_mecab_options(opts))
    end
   
    [ '-l 42',
      '-l42',
      '--lattice-level=42',
      '--lattice-level 42',
      {:lattice_level=>42}
    ].each do |opts|
      assert_equal({:lattice_level => 42}, Natto::MeCab.parse_mecab_options(opts))
    end
   
    [ '-a',
      '--all-morphs',
      {:all_morphs=>true} ].each do |opts|
      assert_equal({:all_morphs => true}, Natto::MeCab.parse_mecab_options(opts))
    end
   
    [ '-O natto',
      '-Onatto',
      '--output-format-type=natto',
      '--output-format-type natto',
      {:output_format_type=>"natto"} ].each do |opts|
      assert_equal({:output_format_type => 'natto'}, Natto::MeCab.parse_mecab_options(opts))
    end
   
    [ '-N 42',
      '-N42',
      '--nbest=42',
      '--nbest 42',
      {:nbest=>42}
    ].each do |opts|
      assert_equal({:nbest => 42}, Natto::MeCab.parse_mecab_options(opts))
    end
    [ '--nbest=-1', '--nbest=0', '--nbest=513' ].each do |bad|
      assert_raises Natto::MeCabError do
        Natto::MeCab.parse_mecab_options(bad)
      end
    end

    [ '-p',
      '--partial',
      {:partial=>true}
    ].each do |opts|
      assert_equal({:partial => true}, Natto::MeCab.parse_mecab_options(opts))
    end
   
    [ '-m',
      '--marginal',
      {:marginal=>true}
    ].each do |opts|
      assert_equal({:marginal => true}, Natto::MeCab.parse_mecab_options(opts))
    end
   
    [ '-M 42',
      '-M42',
      '--max-grouping-size=42',
      '--max-grouping-size 42',
      {:max_grouping_size=>42}
    ].each do |opts|
      assert_equal({:max_grouping_size => 42}, Natto::MeCab.parse_mecab_options(opts))
    end
   
    [ '-F %m\t%f[7]\n',
      '-F%m\t%f[7]\n',
      '--node-format=%m\t%f[7]\n',
      '--node-format %m\t%f[7]\n',
      {:node_format=>'%m\t%f[7]\n'} ].each do |opts|
      assert_equal({:node_format => '%m\t%f[7]\n'}, Natto::MeCab.parse_mecab_options(opts))
    end

    [ '-U %m\t%f[7]\n',
      '-U%m\t%f[7]\n',
      '--unk-format=%m\t%f[7]\n',
      '--unk-format %m\t%f[7]\n',
      {:unk_format=>'%m\t%f[7]\n'} ].each do |opts|
      assert_equal({:unk_format => '%m\t%f[7]\n'}, Natto::MeCab.parse_mecab_options(opts))
    end
    
    [ '-B %m\t%f[7]\n',
      '-B%m\t%f[7]\n',
      '--bos-format=%m\t%f[7]\n',
      '--bos-format %m\t%f[7]\n',
      {:bos_format=>'%m\t%f[7]\n'} ].each do |opts|
      assert_equal({:bos_format => '%m\t%f[7]\n'}, Natto::MeCab.parse_mecab_options(opts))
    end
    
    [ '-E %m\t%f[7]\n',
      '-E%m\t%f[7]\n',
      '--eos-format=%m\t%f[7]\n',
      '--eos-format %m\t%f[7]\n',
      {:eos_format=>'%m\t%f[7]\n'} ].each do |opts|
      assert_equal({:eos_format => '%m\t%f[7]\n'}, Natto::MeCab.parse_mecab_options(opts))
    end
    
    [ '-S %m\t%f[7]\n',
      '-S%m\t%f[7]\n',
      '--eon-format=%m\t%f[7]\n',
      '--eon-format %m\t%f[7]\n',
      {:eon_format=>'%m\t%f[7]\n'} ].each do |opts|
      assert_equal({:eon_format => '%m\t%f[7]\n'}, Natto::MeCab.parse_mecab_options(opts))
    end
    
    [ '-x %m\t%f[7]\n',
      '-x%m\t%f[7]\n',
      '--unk-feature=%m\t%f[7]\n',
      '--unk-feature %m\t%f[7]\n',
      {:unk_feature=>'%m\t%f[7]\n'} ].each do |opts|
      assert_equal({:unk_feature => '%m\t%f[7]\n'}, Natto::MeCab.parse_mecab_options(opts))
    end
    
    [ '-b 102400',
      '-b102400',
      '--input-buffer-size=102400',
      '--input-buffer-size 102400',
      {:input_buffer_size=>102400} ].each do |opts|
      assert_equal({:input_buffer_size => 102400}, Natto::MeCab.parse_mecab_options(opts))
    end
    
    [ '-C',
      '--allocate-sentence',
      {:allocate_sentence=>true} ].each do |opts|
      assert_equal({:allocate_sentence => true}, Natto::MeCab.parse_mecab_options(opts))
    end
    
    [ '-t 0.42',
      '-t0.42',
      '--theta=0.42',
      '--theta 0.42',
      {:theta=>0.42} ].each do |opts|
      assert_equal({:theta => 0.42}, Natto::MeCab.parse_mecab_options(opts))
    end
    
    [ '-c 42',
      '-c42',
      '--cost-factor=42',
      '--cost-factor 42',
      {:cost_factor=>42} ].each do |opts|
      assert_equal({:cost_factor => 42}, Natto::MeCab.parse_mecab_options(opts))
    end

    assert_equal({}, Natto::MeCab.parse_mecab_options)
    assert_equal({}, Natto::MeCab.parse_mecab_options(:unknown=>"ignore"))
  end

  def test_build_options_str
    assert_equal('--rcfile=/some/file', Natto::MeCab.build_options_str(:rcfile=>"/some/file"))
    assert_equal('--dicdir=/some/other/file', Natto::MeCab.build_options_str(:dicdir=>"/some/other/file"))
    assert_equal('--userdic=/yet/another/file', Natto::MeCab.build_options_str(:userdic=>"/yet/another/file"))
    assert_equal('--lattice-level=42', Natto::MeCab.build_options_str(:lattice_level=>42))
    assert_equal('--all-morphs', Natto::MeCab.build_options_str(:all_morphs=>true))
    assert_equal('--output-format-type=natto', Natto::MeCab.build_options_str(:output_format_type=>"natto"))
    assert_equal('--node-format=%m\t%f[7]\n', Natto::MeCab.build_options_str(:node_format=>'%m\t%f[7]\n'))
    assert_equal('--unk-format=%m\t%f[7]\n', Natto::MeCab.build_options_str(:unk_format=>'%m\t%f[7]\n'))
    assert_equal('--bos-format=%m\t%f[7]\n', Natto::MeCab.build_options_str(:bos_format=>'%m\t%f[7]\n'))
    assert_equal('--eos-format=%m\t%f[7]\n', Natto::MeCab.build_options_str(:eos_format=>'%m\t%f[7]\n'))
    assert_equal('--eon-format=%m\t%f[7]\n', Natto::MeCab.build_options_str(:eon_format=>'%m\t%f[7]\n'))
    assert_equal('--unk-feature=%m\t%f[7]\n', Natto::MeCab.build_options_str(:unk_feature=>'%m\t%f[7]\n'))
    assert_equal('--input-buffer-size=102400',Natto::MeCab.build_options_str(:input_buffer_size=>102400))
    assert_equal('--allocate-sentence', Natto::MeCab.build_options_str(:allocate_sentence=>true))
    assert_equal('--nbest=42', Natto::MeCab.build_options_str(:nbest=>42))
    assert_equal('--theta=0.42', Natto::MeCab.build_options_str(:theta=>0.42))
    assert_equal('--cost-factor=42', Natto::MeCab.build_options_str(:cost_factor=>42))
  end

  def test_lattice_level_warning
    [{:lattice_level=>999}, '-l 999', '--lattice-level=999' ].each do |opt|
      out, err = capture_io do
        Natto::MeCab.new opt
      end
      assert_equal ":lattice-level is DEPRECATED, please use :marginal or :nbest\n", err
    end
  end

  def test_initialize_with_errors
    assert_raises Natto::MeCabError do
      Natto::MeCab.new(:output_format_type=>'not_defined_anywhere')
    end
    
    assert_raises Natto::MeCabError do
      Natto::MeCab.new(:rcfile=>'/rcfile/does/not/exist')
    end

    assert_raises Natto::MeCabError do
      Natto::MeCab.new(:dicdir=>'/dicdir/does/not/exist')
    end

    assert_raises Natto::MeCabError do
      Natto::MeCab.new(:userdic=>'/userdic/does/not/exist')
    end
  end

  def test_version_accessor
    assert_equal(@ver, @m.version)
  end

  def test_all_morphs
    m = Natto::MeCab.new(:all_morphs=>true)
    expected = `#{@test_cmd} | mecab --all-morphs`.lines.to_a
    expected.delete_if {|e| e =~ /^(EOS|BOS)/ }
    expected.map!{|e| e.force_encoding(Encoding.default_external)} if @arch =~ /java/i && RUBY_VERSION.to_f >= 1.9
  
    actual   = m.parse(@test_str).lines.to_a
    actual.delete_if {|e| e =~ /^(EOS|BOS|\t)/ }
    
    assert_equal(expected, actual)
  end

  def test_parse_tostr_default
    expected = `#{@test_cmd} | mecab`.lines.to_a
    expected.delete_if {|e| e =~ /^(EOS|BOS|\t)/ }
    expected.map!{|e| e.force_encoding(Encoding.default_external)} if @arch =~ /java/i && RUBY_VERSION.to_f >= 1.9

    actual = @m.parse(@test_str).lines.to_a
    actual.delete_if {|e| e =~ /^(EOS|BOS|\t)/ }

    assert_equal(expected, actual)
  end

  def test_parse_tonode_default
    expected = `#{@test_cmd} | mecab`.lines.to_a
    expected.delete_if {|e| e =~ /^(EOS|BOS|\t)/ }
    expected.map!{|e| e.force_encoding(Encoding.default_external)} if @arch =~ /java/i && RUBY_VERSION.to_f >= 1.9

    actual = []
    @m.parse(@test_str) do |n|
      actual << "#{n.surface}\t#{n.feature}\n" if n.is_nor?
    end

    assert_equal(expected, actual)
  end

  def test_parse_tonodes_with_nodeformatting
    expected = `#{@test_cmd} | mecab -F"%pl\t%f[7]..."`.split("EOS\n").join.split('...')
    expected.map!{|e| e.force_encoding(Encoding.default_external)} if @arch =~ /java/i && RUBY_VERSION.to_f >= 1.9

    actual = []
    @m_f.parse(@test_str) {|n| actual << n if n.is_nor?}    
   
    expected.each_with_index do |f,i|
      sl, y = f.split("\t").map{|e| e.strip}
      asl, ay = actual[i].feature.split('...').first.split("\t").map{|e| e.strip}
      assert_equal(sl, asl)
      assert_equal(y, ay)
    end
  end

  def test_parse_nbest_tostr
    expected = `#{@test_cmd} | mecab -N2`.lines.to_a
    expected.delete_if {|e| e =~ /^(EOS|\t)/ }
    expected.map!{|e| e.force_encoding(Encoding.default_external)} if @arch =~ /java/i && RUBY_VERSION.to_f >= 1.9

    actual = @mn.parse(@test_str).lines.to_a
    actual.delete_if {|e| e =~ /^(EOS|\t)/ }
    
    assert_equal(expected, actual)
  end

  def test_parse_nbest_tonodes
    expected = `#{@test_cmd} | mecab -N2`.lines.to_a
    expected.delete_if {|e| e =~ /^(EOS|\t)/ }
    expected.map!{|e| e.force_encoding(Encoding.default_external)} if @arch =~ /java/i && RUBY_VERSION.to_f >= 1.9

    actual = []
    @mn.parse(@test_str) {|n| actual << n if n.is_nor? }    
  
    expected.each_with_index do |f,i|
      a = actual[i]
      assert_equal(f.strip, "#{a.surface}\t#{a.feature}")
    end
  end

  def test_parse_nbest_with_nodeformatting
    expected = `#{@test_cmd} | mecab -N2 -F"%pl\t%f[7]..."`.split("EOS\n").join.split('...')
    expected.map!{|e| e.force_encoding(Encoding.default_external)} if @arch =~ /java/i && RUBY_VERSION.to_f >= 1.9

    actual = []
    @mn_f.parse(@test_str) {|n| actual << n if n.is_nor?}    
   
    expected.each_with_index do |f,i|
      sl, y = f.split("\t").map{|e| e.strip}
      asl, ay = actual[i].feature.split('...').first.split("\t").map{|e| e.strip}
      assert_equal(sl, asl)
      assert_equal(y, ay)
    end
  end

  def test_parse_nbest_with_wakati
    expected = `#{@test_cmd} | mecab -N4 -Owakati`.lines.to_a
    expected.delete_if {|e| e =~ /^(BOS|EOS|\t)/ }
    expected.map!{|e| e.force_encoding(Encoding.default_external)} if @arch =~ /java/i && RUBY_VERSION.to_f >= 1.9

    actual = @mn_w.parse(@test_str).lines.to_a
    
    assert_equal(expected, actual)
  end

  def test_parse_nbest_nodes_with_wakati
    expected = `#{@test_cmd} | mecab -N4 -Owakati`.lines.to_a
    expected.delete_if {|e| e =~ /^(BOS|EOS|\t)/ }
    expected.map!{|e| e.force_encoding(Encoding.default_external)} if @arch =~ /java/i && RUBY_VERSION.to_f >= 1.9

    tmp = []
    @mn_w.parse(@test_str) {|n| tmp << n }    
    n1 = tmp.slice(0,7).map{|e| e.surface}.join(" ")
    n2 = tmp.slice(8,7).map{|e| e.surface}.join(" ")
    n3 = tmp.slice(16,7).map{|e| e.surface}.join(" ")
    n4 = tmp.slice(24,8).map{|e| e.surface}.join(" ")

    assert_equal(expected[0].strip, n1)
    assert_equal(expected[1].strip, n2)
    assert_equal(expected[2].strip, n3)
    assert_equal(expected[3].strip, n4)
  end

  def test_parse_nbest_with_yomi
    expected = `#{@test_cmd} | mecab -N2 -Oyomi`.lines.to_a
    expected.delete_if {|e| e =~ /^(BOS|EOS|\t)/ }
    expected.map!{|e| e.force_encoding(Encoding.default_external)} if @arch =~ /java/i && RUBY_VERSION.to_f >= 1.9

    actual = @mn_y.parse(@test_str).lines.to_a
    
    assert_equal(expected, actual)
  end
  
  def test_parse_nbest_nodes_with_yomi
    expected = `#{@test_cmd} | mecab -N2 -Oyomi`.lines.to_a
    expected.delete_if {|e| e =~ /^(BOS|EOS|\t)/ }
    expected.map!{|e| e.force_encoding(Encoding.default_external)} if @arch =~ /java/i && RUBY_VERSION.to_f >= 1.9

    tmp = []
    @mn_y.parse(@test_str) {|n| tmp << n }    
    n1 = tmp.slice(0,7).map{|e| e.feature}.join
    n2 = tmp.slice(8,7).map{|e| e.feature}.join

    assert_equal(expected[0].strip, n1)
    assert_equal(expected[1].strip, n2)
  end

  def test_enum_parse_default
    expected = `#{@test_cmd} | mecab`.lines.to_a
    expected.delete_if {|e| e =~ /^(EOS|BOS|\t)/ }
    expected.map!{|e| e.force_encoding(Encoding.default_external)} if @arch =~ /java/i && RUBY_VERSION.to_f >= 1.9

    enum = @e.enum_parse(@test_str)

    assert_equal(expected[0].split.first, enum.next.surface)
    assert_equal(expected[1].split.first, enum.next.surface)
    assert_equal(expected[2].split.first, enum.next.surface)
    assert_equal(expected[3].split.first, enum.next.surface)
    assert_equal(expected[4].split.first, enum.next.surface)
    assert_equal(expected[5].split.first, enum.next.surface)
    assert_equal(expected[6].split.first, enum.next.surface)
  end
  
  def test_enum_parse_with_format
    expected = `#{@test_cmd} | mecab -F"%f[1]#{@br}"`.lines.to_a
    expected.delete_if {|e| e =~ /^(EOS|BOS|\t)/ }
    expected.map!{|e| e.force_encoding(Encoding.default_external)} if @arch =~ /java/i && RUBY_VERSION.to_f >= 1.9

    enum = @e_f.enum_parse(@test_str)

    assert_equal(expected[0].strip, enum.next.feature)
    assert_equal(expected[1].strip, enum.next.feature)
    assert_equal(expected[2].strip, enum.next.feature)
    assert_equal(expected[3].strip, enum.next.feature)
    assert_equal(expected[4].strip, enum.next.feature)
    assert_equal(expected[5].strip, enum.next.feature)
    assert_equal(expected[6].strip, enum.next.feature)
  end

  def test_argument_error
    [ :parse, :enum_parse ].each do |m|
      assert_raises ArgumentError do
        @mn.send(m, nil) 
      end
    end
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

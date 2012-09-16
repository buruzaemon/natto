# coding: utf-8
require 'rbconfig'

class TestMeCab < Test::Unit::TestCase
  def setup
    @m = Natto::MeCab.new
    @mn = Natto::MeCab.new('-N2')
    @mn_f = Natto::MeCab.new('-N2 -F%pl\t%f[7]...')
    @mn_w = Natto::MeCab.new('-N4 -Owakati')
    @mn_y = Natto::MeCab.new('-N2 -Oyomi')
    @ver = `mecab -v`.strip.split.last
    @host_os = RbConfig::CONFIG['host_os']
    @arch    = RbConfig::CONFIG['arch']
    
    if @host_os =~ /mswin|mingw/i
      @test_cmd = 'type "test\\natto\\test_sjis"'
    else
      @test_cmd = 'cat "test/natto/test_utf8"'
    end
    @test_str = `#{@test_cmd}`
  end

  def teardown
    @m          = nil
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
      assert_raise Natto::MeCabError do
        Natto::MeCab.parse_mecab_options(bad)
      end
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

  def test_construction
    m = nil
    assert_nothing_raised do
      m = Natto::MeCab.new
    end
    assert_equal({}, m.options)

    opts = {:output_format_type=>'chasen'}
    assert_nothing_raised do
      m = Natto::MeCab.new(opts)
    end
    assert_equal(opts, m.options)
    assert_nothing_raised do
      m = Natto::MeCab.new("-O chasen")
    end
    assert_equal(opts, m.options)
    assert_nothing_raised do
      m = Natto::MeCab.new("--output-format-type=chasen")
    end
    assert_equal(opts, m.options)
    
    opts = {:all_morphs=>true, :allocate_sentence=>true}
    assert_nothing_raised do
      m = Natto::MeCab.new(opts)
    end
    assert_equal(opts, m.options)
    assert_nothing_raised do
      m = Natto::MeCab.new('-a -C')
    end
    assert_equal(opts, m.options)
    assert_nothing_raised do
      m = Natto::MeCab.new('--all-morphs --allocate-sentence')
    end
    assert_equal(opts, m.options)
    
    opts = {:lattice_level=>999}
    assert_nothing_raised do
      m = Natto::MeCab.new(opts)
    end
    assert_equal(opts, m.options)
    assert_nothing_raised do
      m = Natto::MeCab.new('-l 999')
    end
    assert_equal(opts, m.options)
    assert_nothing_raised do
      m = Natto::MeCab.new('--lattice-level=999')
    end
    assert_equal(opts, m.options)
  end

  def test_initialize_with_errors
    assert_raise Natto::MeCabError do
      Natto::MeCab.new(:output_format_type=>'not_defined_anywhere')
    end
    
    assert_raise Natto::MeCabError do
      Natto::MeCab.new(:rcfile=>'/rcfile/does/not/exist')
    end

    assert_raise Natto::MeCabError do
      Natto::MeCab.new(:dicdir=>'/dicdir/does/not/exist')
    end

    assert_raise Natto::MeCabError do
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
  
  def test_parse_as_strings
    expected = `#{@test_cmd} | mecab -N2`.lines.to_a
    expected.delete_if {|e| e =~ /^(EOS|\t)/ }
    expected.map!{|e| e.force_encoding(Encoding.default_external)} if @arch =~ /java/i && RUBY_VERSION.to_f >= 1.9

    actual = @mn.parse_as_strings(@test_str)
    actual.delete_if {|e| e =~ /^(EOS|\t)/ }
    
    assert_equal(expected, actual)
  end

  def test_parse_as_nodes
    expected = `#{@test_cmd} | mecab -N2`.lines.to_a
    expected.delete_if {|e| e =~ /^(EOS|\t)/ }
    expected.map!{|e| e.force_encoding(Encoding.default_external)} if @arch =~ /java/i && RUBY_VERSION.to_f >= 1.9

    actual = @mn.parse_as_nodes(@test_str).reject {|n| !n.is_nor? }    
  
    expected.each_with_index do |f,i|
      a = actual[i]
      assert_equal(f.strip, "#{a.surface}\t#{a.feature}")
    end
  end

  def test_argument_error
    [ :parse, :parse_as_nodes, :parse_as_strings ].each do |m|
      assert_raise ArgumentError do
        @mn.send(m, nil) 
      end
    end
  end
end 

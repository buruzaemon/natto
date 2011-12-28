# coding: utf-8
require 'rbconfig'
require 'nkf'

# TestMeCab encapsulates tests for the basic
# behavior of Natto::MeCab.
class TestMeCab < Test::Unit::TestCase

  host_os = RbConfig::CONFIG['host_os']
  # we need to transfrom from UTF-8 ot SJIS if we are on Windows!
  if host_os =~ /mswin|mingw/i
    TEST_STR = NKF.nkf("-Ws", '試験ですよ、これが。')
  else
    TEST_STR = '試験ですよ、これが。'
  end

  def setup
    @m = Natto::MeCab.new
    @ver = `mecab -v`.strip.split.last
  end

  def teardown
    @m = nil
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
    expected = `echo #{TEST_STR} | mecab --all-morphs`.lines.to_a
    expected.delete_if {|e| e =~ /^(EOS|BOS)/ }
    
    actual   = m.parse(TEST_STR).lines.to_a
    actual.delete_if {|e| e =~ /^(EOS|BOS|\t)/ }
    
    assert_equal(expected, actual)
  end

  def test_parse_tostr_default
    expected = `echo #{TEST_STR} | mecab`.lines.to_a
    expected.delete_if {|e| e =~ /^(EOS|BOS|\t)/ }

    actual = @m.parse(TEST_STR).lines.to_a
    actual.delete_if {|e| e =~ /^(EOS|BOS|\t)/ }

    assert_equal(expected, actual)
  end

  def test_parse_tonode_default
    expected = `echo #{TEST_STR} | mecab`.lines.to_a
    expected.delete_if {|e| e =~ /^(EOS|BOS|\t)/ }

    actual = []
    @m.parse(TEST_STR) do |node|
      actual << "#{node.surface}\t#{node.feature}\n"
    end
    actual.delete_if {|e| e =~ /^(EOS|BOS|\t)/ }

    assert_equal(expected, actual)
  end
end 

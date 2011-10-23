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
  end

  def teardown
    @m = nil
  end

  def test_parse_mecab_options
    assert_equal({:rcfile => '/some/file'}, Natto::MeCab.parse_mecab_options('-r /some/file'))
    assert_equal({:rcfile => '/some/file'}, Natto::MeCab.parse_mecab_options('--rcfile=/some/file'))
    assert_equal({:rcfile => '/some/file'}, Natto::MeCab.parse_mecab_options(:rcfile=>"/some/file"))
    
    assert_equal({:dicdir => '/some/other/file'}, Natto::MeCab.parse_mecab_options('-d /some/other/file'))
    assert_equal({:dicdir => '/some/other/file'}, Natto::MeCab.parse_mecab_options('--dicdir=/some/other/file'))
    assert_equal({:dicdir => '/some/other/file'}, Natto::MeCab.parse_mecab_options(:dicdir=>"/some/other/file"))
    
    assert_equal({:userdic => '/yet/another/file'}, Natto::MeCab.parse_mecab_options('-u /yet/another/file'))
    assert_equal({:userdic => '/yet/another/file'}, Natto::MeCab.parse_mecab_options('--userdic=/yet/another/file'))
    assert_equal({:userdic => '/yet/another/file'}, Natto::MeCab.parse_mecab_options(:userdic=>"/yet/another/file"))
    
    assert_equal({:lattice_level => 42}, Natto::MeCab.parse_mecab_options('-l 42'))
    assert_equal({:lattice_level => 42}, Natto::MeCab.parse_mecab_options('--lattice-level=42'))
    assert_equal({:lattice_level => 42}, Natto::MeCab.parse_mecab_options(:lattice_level=>42))
    
    assert_equal({:all_morphs => true}, Natto::MeCab.parse_mecab_options('-a'))
    assert_equal({:all_morphs => true}, Natto::MeCab.parse_mecab_options('--all-morphs'))
    assert_equal({:all_morphs => true}, Natto::MeCab.parse_mecab_options(:all_morphs=>true))
    
    assert_equal({:output_format_type => 'natto'}, Natto::MeCab.parse_mecab_options('-O natto'))
    assert_equal({:output_format_type => 'natto'}, Natto::MeCab.parse_mecab_options('--output-format-type=natto'))
    assert_equal({:output_format_type => 'natto'}, Natto::MeCab.parse_mecab_options(:output_format_type=>"natto"))
    
    assert_equal({:node_format => '%m\t%f[7]\n'}, Natto::MeCab.parse_mecab_options('-F %m\t%f[7]\n'))
    assert_equal({:node_format => '%m\t%f[7]\n'}, Natto::MeCab.parse_mecab_options('--node-format=%m\t%f[7]\n'))
    assert_equal({:node_format => '%m\t%f[7]\n'}, Natto::MeCab.parse_mecab_options(:node_format=>'%m\t%f[7]\n'))
    
    assert_equal({:unk_format => '%m\t%f[7]\n'}, Natto::MeCab.parse_mecab_options('-U %m\t%f[7]\n'))
    assert_equal({:unk_format => '%m\t%f[7]\n'}, Natto::MeCab.parse_mecab_options('--unk-format=%m\t%f[7]\n'))
    assert_equal({:unk_format => '%m\t%f[7]\n'}, Natto::MeCab.parse_mecab_options(:unk_format=>'%m\t%f[7]\n'))
    
    assert_equal({:bos_format => '%m\t%f[7]\n'}, Natto::MeCab.parse_mecab_options('-B %m\t%f[7]\n'))
    assert_equal({:bos_format => '%m\t%f[7]\n'}, Natto::MeCab.parse_mecab_options('--bos-format=%m\t%f[7]\n'))
    assert_equal({:bos_format => '%m\t%f[7]\n'}, Natto::MeCab.parse_mecab_options(:bos_format=>'%m\t%f[7]\n'))
    
    assert_equal({:eos_format => '%m\t%f[7]\n'}, Natto::MeCab.parse_mecab_options('-E %m\t%f[7]\n'))
    assert_equal({:eos_format => '%m\t%f[7]\n'}, Natto::MeCab.parse_mecab_options('--eos-format=%m\t%f[7]\n'))
    assert_equal({:eos_format => '%m\t%f[7]\n'}, Natto::MeCab.parse_mecab_options(:eos_format=>'%m\t%f[7]\n'))
    
    assert_equal({:eon_format => '%m\t%f[7]\n'}, Natto::MeCab.parse_mecab_options('-S %m\t%f[7]\n'))
    assert_equal({:eon_format => '%m\t%f[7]\n'}, Natto::MeCab.parse_mecab_options('--eon-format=%m\t%f[7]\n'))
    assert_equal({:eon_format => '%m\t%f[7]\n'}, Natto::MeCab.parse_mecab_options(:eon_format=>'%m\t%f[7]\n'))
    
    assert_equal({:unk_feature => '%m\t%f[7]\n'}, Natto::MeCab.parse_mecab_options('-x %m\t%f[7]\n'))
    assert_equal({:unk_feature => '%m\t%f[7]\n'}, Natto::MeCab.parse_mecab_options('--unk-feature=%m\t%f[7]\n'))
    assert_equal({:unk_feature => '%m\t%f[7]\n'}, Natto::MeCab.parse_mecab_options(:unk_feature=>'%m\t%f[7]\n'))
    
    assert_equal({:input_buffer_size => 102400}, Natto::MeCab.parse_mecab_options('-b 102400'))
    assert_equal({:input_buffer_size => 102400}, Natto::MeCab.parse_mecab_options('--input-buffer-size=102400'))
    assert_equal({:input_buffer_size => 102400}, Natto::MeCab.parse_mecab_options(:input_buffer_size=>102400))
    
    assert_equal({:allocate_sentence => true}, Natto::MeCab.parse_mecab_options('-C'))
    assert_equal({:allocate_sentence => true}, Natto::MeCab.parse_mecab_options('--allocate-sentence'))
    assert_equal({:allocate_sentence => true}, Natto::MeCab.parse_mecab_options(:allocate_sentence=>true))
    
    assert_equal({:nbest => 42}, Natto::MeCab.parse_mecab_options('-N 42'))
    assert_equal({:nbest => 42}, Natto::MeCab.parse_mecab_options('--nbest=42'))
    assert_equal({:nbest => 42}, Natto::MeCab.parse_mecab_options(:nbest=>42))
    
    assert_equal({:theta => 0.42}, Natto::MeCab.parse_mecab_options('-t 0.42'))
    assert_equal({:theta => 0.42}, Natto::MeCab.parse_mecab_options('--theta=0.42'))
    assert_equal({:theta => 0.42}, Natto::MeCab.parse_mecab_options(:theta=>0.42))
    
    assert_equal({:cost_factor => 42}, Natto::MeCab.parse_mecab_options('-c 42'))
    assert_equal({:cost_factor => 42}, Natto::MeCab.parse_mecab_options('--cost-factor=42'))
    assert_equal({:cost_factor => 42}, Natto::MeCab.parse_mecab_options(:cost_factor=>42))

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

  # Tests the construction and initial state of a Natto::MeCab instance.
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

  # Tests the initialize method for error cases for erroneous mecab options.
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

  # Tests the mecab version string accessor class method of Natto::MeCab.
  def test_version_accessor
    assert_equal('0.98', @m.version)
  end

  # Tests Natto::MeCab parsing using the --all-morphs option.
  def test_all_morphs
    m = Natto::MeCab.new(:all_morphs=>true)
    expected = `echo #{TEST_STR} | mecab --all-morphs`.lines.to_a
    expected.delete_if {|e| e =~ /^(EOS|BOS)/ }
    
    actual   = m.parse(TEST_STR).lines.to_a
    actual.delete_if {|e| e =~ /^(EOS|BOS|\t)/ }
    
    assert_equal(expected, actual)
  end

  # Tests Natto::MeCab parsing (default parse_tostr).
  def test_parse_tostr_default
    expected = `echo #{TEST_STR} | mecab`.lines.to_a
    expected.delete_if {|e| e =~ /^(EOS|BOS|\t)/ }

    actual = @m.parse(TEST_STR).lines.to_a
    actual.delete_if {|e| e =~ /^(EOS|BOS|\t)/ }

    assert_equal(expected, actual)
  end

  # Tests Natto::MeCab parsing (default parse_tonode).
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

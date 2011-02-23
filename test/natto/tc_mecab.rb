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

  # Tests the Natto::MeCab.build_options_str function.
  def test_build_options_str
    res = Natto::MeCab.build_options_str
    assert_equal('', res)

    res = Natto::MeCab.build_options_str(:unknown=>"ignore")
    assert_equal('', res)

    res = Natto::MeCab.build_options_str(:rcfile=>"/some/file")
    assert_equal('--rcfile=/some/file', res)

    res = Natto::MeCab.build_options_str(:dicdir=>"/some/other/file")
    assert_equal('--dicdir=/some/other/file', res)

    res = Natto::MeCab.build_options_str(:userdic=>"/yet/another/file")
    assert_equal('--userdic=/yet/another/file', res)

    res = Natto::MeCab.build_options_str(:lattice_level=>42)
    assert_equal('--lattice-level=42', res)

    res = Natto::MeCab.build_options_str(:all_morphs=>true)
    assert_equal('--all-morphs', res)

    res = Natto::MeCab.build_options_str(:output_format_type=>"natto")
    assert_equal('--output-format-type=natto', res)
    
    res = Natto::MeCab.build_options_str(:node_format=>'%m\t%f[7]\n')
    assert_equal('--node-format=%m\t%f[7]\n', res)
    
    res = Natto::MeCab.build_options_str(:unk_format=>'%m\t%f[7]\n')
    assert_equal('--unk-format=%m\t%f[7]\n', res)

    res = Natto::MeCab.build_options_str(:bos_format=>'%m\t%f[7]\n')
    assert_equal('--bos-format=%m\t%f[7]\n', res)

    res = Natto::MeCab.build_options_str(:eos_format=>'%m\t%f[7]\n')
    assert_equal('--eos-format=%m\t%f[7]\n', res)

    res = Natto::MeCab.build_options_str(:eon_format=>'%m\t%f[7]\n')
    assert_equal('--eon-format=%m\t%f[7]\n', res)

    res = Natto::MeCab.build_options_str(:unk_feature=>'%m\t%f[7]\n')
    assert_equal('--unk-feature=%m\t%f[7]\n', res)

    res = Natto::MeCab.build_options_str(:input_buffer_size=>102400)
    assert_equal('--input-buffer-size=102400', res)

    res = Natto::MeCab.build_options_str(:allocate_sentence=>true)
    assert_equal('--allocate-sentence', res)

    res = Natto::MeCab.build_options_str(:nbest=>42)
    assert_equal('--nbest=42', res)

    res = Natto::MeCab.build_options_str(:theta=>0.42)
    assert_equal('--theta=0.42', res)

    res = Natto::MeCab.build_options_str(:cost_factor=>42)
    assert_equal('--cost-factor=42', res)
    
    res = Natto::MeCab.build_options_str(:output_format_type=>"natto", 
                                         :userdic=>"/some/file", 
                                         :dicdir=>"/some/other/file",
                                         :all_morphs=>true)
    assert_equal('--dicdir=/some/other/file --userdic=/some/file --all-morphs --output-format-type=natto', res)
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
    
    opts = {:all_morphs=>true, :allocate_sentence=>true}
    assert_nothing_raised do
      m = Natto::MeCab.new(opts)
    end
    assert_equal(opts, m.options)
    
    opts = {:lattice_level=>999}
    assert_nothing_raised do
      m = Natto::MeCab.new(opts)
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

  # Tests mecab parsing using the --all-morphs option.
  def test_all_morphs
    m = Natto::MeCab.new(:all_morphs=>true)
    expected = `echo #{TEST_STR} | mecab -a`.lines.to_a
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

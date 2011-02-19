# coding: utf-8

# TestMeCab encapsulates tests for the basic
# behavior of Natto::MeCab.
class TestMeCab < Test::Unit::TestCase
  def setup
    @m = Natto::MeCab.new
    @mecab = '/usr/local/bin/mecab'
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
    s = '天使'
    expected = `echo #{s} | #{@mecab} -a`
    actual   = m.parse(s)
    assert_equal(expected, actual)
    #assert_equal(expected.force_encoding('ASCII-8BIT'), actual)
  end

  def test_parse_tostr_default
    s = 'これはペンです。'
    expected = `echo #{s} | #{@mecab}`.lines.to_a
    actual = @m.parse(s).lines.to_a
    assert_equal(expected, actual)
    #puts expected.force_encoding('ASCII-8BIT')
    #puts actual
    #assert_equal(expected.force_encoding('ASCII-8BIT'), actual)
  end

  def test_parse_tonode_default
    s = '俺の名はハカイダーである。'
    expected = `echo #{s} | #{@mecab}`.lines.to_a
    #expected.collect! {|e| e = e.force_encoding('ASCII-8BIT')}

    actual = []
    @m.parse(s) do |node|
      actual << "#{node.surface}\t#{node.feature}\n"
    end
    # do not include the EOS that gets added when using command line
    expected.pop
    actual.pop
    assert_equal(expected, actual)
  end
end 

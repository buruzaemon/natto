# -*- encoding: utf-8 -*-
$:.unshift('lib')
require 'rubygems' if RUBY_VERSION.to_f < 1.9
require 'test/unit'
require 'natto'

class TestNatto < Test::Unit::TestCase
  def setup
    @klass = Class.new do
      include Natto::Binding
    end
  end

  def teardown
  end

  def test_classmethods_include
    assert_equal('0.98', @klass.mecab_version)
  end

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
    
    res = Natto::MeCab.build_options_str(:partial=>true)
    assert_equal('--partial', res)

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

    res = Natto::MeCab.build_options_str(:nbest=>42)
    assert_equal('--nbest=42', res)

    res = Natto::MeCab.build_options_str(:theta=>0.42)
    assert_equal('--theta=0.42', res)

    res = Natto::MeCab.build_options_str(:cost_factor=>42)
    assert_equal('--cost-factor=42', res)
    
    res = Natto::MeCab.build_options_str(:output_format_type=>"natto", 
                                         :userdic=>"/some/file", 
                                         :dicdir=>"/some/other/file",
                                         :partial=>true,
                                         :all_morphs=>true)
    assert_equal('--dicdir=/some/other/file --userdic=/some/file --all-morphs --output-format-type=natto --partial', res)

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
    
    opts = {:all_morphs=>true, :partial=>true}
    assert_nothing_raised do
      m = Natto::MeCab.new(opts)
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

  def test_dictionary_accessor
    m = Natto::MeCab.new
    dicts = m.dicts
    assert dicts.empty? == false
    sysdic = dicts.first
    assert_equal('/usr/local/lib/mecab/dic/ipadic/sys.dic', sysdic[:filename])
    assert_equal('utf8', sysdic[:charset])
    assert_equal(0x0, sysdic[:next].address)
  end
end

# -*- coding: UTF-8 -*-
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

    res = Natto::MeCab.build_options_str(:dicdir=>"a")
    assert_equal('--dicdir=a', res)

    res = Natto::MeCab.build_options_str(:userdic=>"b")
    assert_equal('--userdic=b', res)

    res = Natto::MeCab.build_options_str(:output_format_type=>"c")
    assert_equal('--output-format-type=c', res)

    res = Natto::MeCab.build_options_str(:output_format_type=>"c", :userdic=>"b", :dicdir=>"a")
    assert_equal('--dicdir=a --userdic=b --output-format-type=c', res)
  end

  def test_initialize
    assert_raise Natto::MeCabError do
      Natto::MeCab.new(:output_format_type=>'UNDEFINED')
    end
  end
end

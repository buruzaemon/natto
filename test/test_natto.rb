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
end

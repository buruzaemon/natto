# coding: utf-8
$: << 'lib'
require 'rubygems' if RUBY_VERSION.to_f < 1.9
require 'test/unit'
require 'natto'

[ 
  '/test/natto/tc_mecab.rb',
  '/test/natto/tc_mecabnode.rb',
  '/test/natto/tc_binding.rb',
  '/test/natto/tc_dictionaryinfo.rb'
].each do |tc|
  require File.join(File.expand_path('.'), tc)
end

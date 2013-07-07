# coding: utf-8
$: << 'lib'
require 'minitest/autorun'
require 'natto'

[ 
  '/test/natto/tc_binding.rb',
  '/test/natto/tc_dictionaryinfo.rb',
  '/test/natto/tc_mecab.rb',
  '/test/natto/tc_mecabnode.rb',
  '/test/natto/tc_option_parse.rb'
].each do |tc|
  require File.join(File.expand_path('.'), tc)
end

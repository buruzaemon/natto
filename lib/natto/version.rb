# coding: utf-8

# natto combines the Ruby programming language with MeCab, 
# the part-of-speech and morphological analyzer for the
# Japanese language.
# 
# ## Requirements
# natto requires the following:
#
# -  [MeCab _0.98_](http://sourceforge.net/projects/mecab/files/mecab/0.98/)
# -  [ffi _0.6.3 or greater_](http://rubygems.org/gems/ffi)
# -  Ruby _1.8.7 or greater_
#
# ## Installation
# Install natto with the following gem command:
#     gem install natto
#
# ## Configuration
# - natto will try to locate the <tt>mecab</tt> library based upon its runtime environment.
# - In case of <tt>LoadError</tt>, please set the <tt>MECAB_PATH</tt> environment variable to the exact name/path to your <tt>mecab</tt> library.
#
#  e.g., for bash on UNIX/Linux
#       export MECAB_PATH=mecab.so
#  e.g., on Windows
#       set MECAB_PATH=C:\Program Files\MeCab\bin\libmecab.dll
#  e.g., for Cygwin
#       export MECAB_PATH=cygmecab-1
#
# ## Usage
# 
#       require 'natto'
#
#       m = Natto::MeCab.new
#       => #<Natto::MeCab:0x28d93dd4 @options={}, \
#                                    @dicts=[#<Natto::DictionaryInfo:0x28d93d34>], \
#                                    @ptr=#<FFI::Pointer address=0x28af3e58>>
#       puts m.parse("すもももももももものうち")
#       すもも  名詞,一般,*,*,*,*,すもも,スモモ,スモモ
#       も      助詞,係助詞,*,*,*,*,も,モ,モ
#       もも    名詞,一般,*,*,*,*,もも,モモ,モモ
#       も      助詞,係助詞,*,*,*,*,も,モ,モ
#       もも    名詞,一般,*,*,*,*,もも,モモ,モモ
#       の      助詞,連体化,*,*,*,*,の,ノ,ノ
#       うち    名詞,非自立,副詞可能,*,*,*,うち,ウチ,ウチ
#       EOS
#       => nil
module Natto
  # Version string for this Rubygem.
  VERSION = "0.0.8"
end

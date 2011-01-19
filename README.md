# natto
A Tasty Ruby Binding with MeCab

## What is natto?
natto combines the [Ruby programming language](http://www.ruby-lang.org/) with [MeCab](http://mecab.sourceforge.net/), the part-of-speech and morphological analyzer for the Japanese language.

## Requirements
natto requires the following:

-  [MeCab _0.98_](http://sourceforge.net/projects/mecab/files/mecab/0.98/)
-  [ffi _0.6.3 or greater_](http://rubygems.org/gems/ffi)
-  Ruby _1.8.7 or greater_

## Installation
Install natto with the following gem command:
    gem install natto

## Configuration
-  natto will try to locate the <tt>mecab</tt> library based upon its runtime environment.
-  In case of <tt>LoadError</tt>, please set the <tt>MECAB_PATH</tt> environment variable to the exact name/path to your <tt>mecab</tt> library.

e.g., for bash on UNIX/Linux
    export MECAB_PATH=mecab.so
e.g., on Windows
    set MECAB_PATH=C:\Program Files\MeCab\bin\libmecab.dll
e.g., for Cygwin
    export MECAB_PATH=cygmecab-1

## Usage
    require 'rubygems' if RUBY_VERSION.to_f < 1.9
    require 'natto'

    mecab = Natto::MeCab.new
    => #<Natto::MeCab:0x28d93dd4 @options={}, \
                                 @dicts=[#<Natto::DictionaryInfo:0x28d93d34>], \
                                 @ptr=#<FFI::Pointer address=0x28af3e58>>

    puts mecab.version
    => 0.98

    sysdic = mecab.dicts.first
    puts sysdic.filename
    => /usr/local/lib/mecab/dic/ipadic/sys.dic

    puts sysdic.charset
    => utf8

    puts mecab.parse('暑い日にはもってこいの一品ですね。')
    暑い    形容詞,自立,*,*,形容詞・アウオ段,基本形,暑い,アツイ,アツイ
    日      名詞,非自立,副詞可能,*,*,*,日,ヒ,ヒ
    に      助詞,格助詞,一般,*,*,*,に,ニ,ニ
    は      助詞,係助詞,*,*,*,*,は,ハ,ワ
    もってこい 名詞,一般,*,*,*,*,もってこい,モッテコイ,モッテコイ
    の      助詞,連体化,*,*,*,*,の,ノ,ノ
    一品    名詞,一般,*,*,*,*,一品,イッピン,イッピン
    です    助動詞,*,*,*,特殊・デス,基本形,です,デス,デス
    ね      助詞,終助詞,*,*,*,*,ね,ネ,ネ
    。      終助詞記号,句点,*,*,*,*,。,。,。
    EOS
    => nil

## Contributing to natto
-  Use [Mercurial](http://mercurial.selenic.com/) and [check out the latest master](http://code.google.com/p/natto/source/checkout) to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
-  [Check out the issue tracker](http://code.google.com/p/natto/issues/list) to make sure someone already hasn't requested it and/or contributed it.
-  Fork the project.
-  Start a feature/bugfix branch.
-  Commit and push until you are happy with your contribution.
-  Make sure to add tests for it. This is important so I don't break it in a future version unintentionally. I use [Test::Unit](http://ruby-doc.org/stdlib/libdoc/test/unit/rdoc/classes/Test/Unit.html) since it is simple and it works.
-  Please try not to mess with the Rakefile, version, or history. If you must have your own version, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Changelog

- __2011/01/19__: 0.2.0 release.
    - Added support for mecab option allocate-sentence 
    - Continuing update of documentation

- __2011/01/15__: 0.1.1 release.
    - Refactored Natto::DictionaryInfo#method_missing
    - Continuing update of documentation

- __2011/01/15__: 0.1.0 release.
    - Added accessors to Natto::DictionaryInfo
    - Added accessor for version in Natto::MeCab
    - Continuing update of documentation

- __2011/01/13__: 0.0.9 release.
    - Further development and testing for mecab dictionary access/destruction
    - Continuing update of documentation

- __2011/01/07__: 0.0.8 release.
    - Adding support for accessing dictionaries 
    - Further tweaking of documentation with markdown

- __2010/12/30__: 0.0.7 release.
    - Adding support for all-morphs and partial options
    - Further updating of documentation with markdown

- __2010/12/28__: 0.0.6 release.
    - Correction to natto.gemspec to include lib/natto/binding.rb

- __2010/12/28__: 0.0.5 release. (yanked)
    - On-going refactoring
    - Project structure refactored for greater maintainability

- __2010/12/26__: 0.0.4 release.
    - On-going refactoring

- __2010/12/23__: 0.0.3 release.
    - On-going refactoring
    - Adding documentation via yard

- __2010/12/20__: 0.0.2 release.
    - Continuing development on proper resource deallocation
    - Adding options hash in object initializer 

- __2010/12/13__: Released version 0.0.1. The objective is to provide
  an easy-to-use, production-level Ruby binding to MeCab.
    - Initial release 

## Copyright
Copyright &copy; 2010-2013, Brooke M. Fujita.
All rights reserved.
 
Redistribution and use in source and binary forms, with or without modification, are
permitted provided that the following conditions are met:
 
  * Redistributions of source code must retain the above
    copyright notice, this list of conditions and the
    following disclaimer.
 
  * Redistributions in binary form must reproduce the above
    copyright notice, this list of conditions and the
    following disclaimer in the documentation and/or other
    materials provided with the distribution.
 
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED
WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

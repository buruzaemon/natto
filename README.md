# natto
A Tasty Ruby Binding with MeCab

## What is natto?
natto combines the [Ruby programming language](http://www.ruby-lang.org/) with [MeCab](http://mecab.sourceforge.net/), the part-of-speech and morphological analyzer for the Japanese language.

natto is a gem bridging Ruby and MeCab using FFI (foreign function interface). No compilation is necessary, as natto is _not_ a C extension. natto will run on CRuby (mri/yarv) and JRuby (jvm) equally well. natto will also run on Windows, Unix/Linux, and Mac.

You can learn more about [natto at bitbucket](https://bitbucket.org/buruzaemon/natto/).

## Requirements
natto requires the following:

-  [MeCab _0.993_](http://code.google.com/p/mecab/downloads/list)
-  [ffi _0.6.3 or greater_](http://rubygems.org/gems/ffi)
-  Ruby _1.8.7 or greater_

## Installation
Install natto with the following gem command:
    gem install natto

## Configuration
-  natto will try to locate the <tt>mecab</tt> library based upon its runtime environment.
-  In case of <tt>LoadError</tt>, please set the <tt>MECAB_PATH</tt> environment variable to the exact name/path to your <tt>mecab</tt> library.

e.g., for bash on UNIX/Linux
    export MECAB_PATH=/usr/local/lib/libmecab.so
e.g., on Windows
    set MECAB_PATH=C:\Program Files\MeCab\bin\libmecab.dll
e.g., for Cygwin
    export MECAB_PATH=cygmecab-1
e.g., from within a Ruby program
    ENV['MECAB_PATH']=/usr/local/lib/libmecab.so

## Usage
    require 'rubygems' if RUBY_VERSION.to_f < 1.9
    require 'natto'

    nm = Natto::MeCab.new
    => #<Natto::MeCab:0x28d30748 
         @ptr=#<FFI::Pointer address=0x28a97d50>, \
         @options={}, \
         @dicts=[#<Natto::DictionaryInfo:0x28d3061c 
                 filename="/usr/local/lib/mecab/dic/ipadic/sys.dic", 
                 charset="utf8">], 
         @version="0.993">

    puts nm.version
    => "0.993" 

    sysdic = nm.dicts.first

    puts sysdic.filename
    => "/usr/local/lib/mecab/dic/ipadic/sys.dic"

    puts sysdic.charset
    => "utf8" 

    nm.parse('暑い日にはもってこいの一品ですね。') do |n|
      puts "#{n.surface}\t#{n.feature}"
    end
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
            BOS/EOS,*,*,*,*,*,*,*,*
    => nil

## Contributing to natto
-  Use [mercurial](http://mercurial.selenic.com/) and [check out the latest code at bitbucket](https://bitbucket.org/buruzaemon/natto/src/) to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
-  [Browse the issue tracker](https://bitbucket.org/buruzaemon/natto/issues/) to make sure someone already hasn't requested it and/or contributed it.
-  Fork the project.
-  Start a feature/bugfix branch.
-  Commit and push until you are happy with your contribution.
-  Make sure to add tests for it. This is important so I don't break it in a future version unintentionally. I use [Test::Unit](http://ruby-doc.org/stdlib/libdoc/test/unit/rdoc/classes/Test/Unit.html) since it is simple and it works.
-  Please try not to mess with the Rakefile, version, or history. If you must have your own version, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Changelog
Please see the {file:CHANGELOG} for this gem's release history.

## Copyright
Copyright &copy; 2011, Brooke M. Fujita. All rights reserved. Please see the {file:LICENSE} file for further details. 

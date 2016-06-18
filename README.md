# natto [![Gem Version](https://badge.fury.io/rb/natto.svg)](https://rubygems.org/gems/natto) [![Build Status](https://travis-ci.org/buruzaemon/natto.svg?branch=master)](https://travis-ci.org/buruzaemon/natto) [![Gem Downloads](https://img.shields.io/gem/dt/natto.svg)](https://rubygems.org/gems/natto) [![Gem License](https://img.shields.io/badge/license-BSD-blue.svg)]() 
A Tasty Ruby Binding with MeCab

## What is natto?
A gem leveraging FFI (foreign function interface), natto combines the
[Ruby programming language](http://www.ruby-lang.org/) with 
[MeCab](http://taku910.github.io/mecab/), the part-of-speech
and morphological analyzer for the Japanese language.

-  natto provides a naturally Ruby-esque interface to MeCab.
-  It runs on both CRuby (mri/yarv) and JRuby (jvm).
-  It works with MeCab installations on Windows, Unix/Linux and OS X.
-  No compiler is necessary, as natto is _not_ a C extension.

You can learn more about [natto at GitHub](https://github.com/buruzaemon/natto).


## Requirements
natto requires the following:

-  [MeCab _0.996_](http://taku910.github.io/mecab/#download)
-  A system dictionary, like mecab-ipadic (recommended), mecab-jumandic or unidic, all available on the [MeCab downloads page](http://taku910.github.io/mecab/#download)
-  `libmecab-devel` if you are on Linux, since natto uses `mecab-config`
-  Ruby _1.9 or greater_
-  [ffi _1.9.0 or greater_](http://rubygems.org/gems/ffi)

## Installation on *nix and OS X
Install natto with the following gem command:

    gem install natto

This will automatically install the [ffi](http://rubygems.org/gems/ffi) rubygem, which natto uses to bind to the MeCab library.

## Installation on Windows 
However, if you are using a CRuby on Windows, then you will first need to install the [RubyInstaller Development Kit (DevKit)](https://github.com/oneclick/rubyinstaller/wiki/Development-Kit), a MSYS/MinGW based toolkit that enables your Windows Ruby installation to build many of the native C/C++ extensions available, including ffi.

1. Download the latest release for RubyInstaller for Windows platforms and the corresponding DevKit from the [RubyInstaller for Windows downloads page](http://rubyinstaller.org/downloads/).
2. After installing RubyInstaller for Windows, double-click on the DevKit-tdm installer `.exe`, and expand the contents to an appropriate location, for example `C:\devkit`.
3. Open a command window under `C:\devkit`, and execute: `ruby dk.rb init`. This will locate all known ruby installations, and add them to `C:\devkit\config.yml`.
4. Next, execute: `ruby dk.rb install`, which will add the DevKit to all of the installed rubies listed in your `C:\devkit\config.yml`. Now you should be able to install and build the ffi rubygem correctly on your Windows-installed ruby. 
5. Install natto with: 

        gem install natto

6. If you are on a 64-bit Windows and you use a 64-bit Ruby or JRuby, then you might want to [build a 64-bit version of libmecab.dll](https://github.com/buruzaemon/natto/wiki/64-Bit-Windows).


## Automatic Configuration
No explicit configuration should be necessary, as natto will try to locate the MeCab library based upon its runtime environment.

- On OS X and \*nix, it will query `mecab-config --libs` 
- On Windows, it will query the Windows Registry to determine where `libmecab.dll` is installed

## Explicit configuration via `MECAB_PATH` and `MECAB_CHARSET`
If natto cannot find the MeCab library, `LoadError` will be raised. Please set the `MECAB_PATH` environment variable to the exact name/path to your MeCab library.

- e.g., for OS X

        export MECAB_PATH=/usr/local/Cellar/mecab/0.996/lib/libmecab.dylib 

- e.g., for bash on UNIX/Linux

        export MECAB_PATH=/usr/local/lib/libmecab.so

- e.g., on Windows

        set MECAB_PATH=C:\Program Files\MeCab\bin\libmecab.dll

- e.g., from within a Ruby program

        ENV['MECAB_PATH']='/usr/local/lib/libmecab.so'

## Usage

Here's a very quick guide to using natto.

Instantiate a reference to the MeCab library, and display some details:

    require 'natto'

    nm = Natto::MeCab.new
    => #<Natto::MeCab:0x00000803633ae8
         @model=#<FFI::Pointer address=0x000008035d4640>,             \
         @tagger=#<FFI::Pointer address=0x00000802b07c90>,            \
         @lattice=#<FFI::Pointer address=0x00000803602f80>,           \
         @libpath="/usr/local/lib/libmecab.so",                       \
         @options={},                                                 \
         @dicts=[#<Natto::DictionaryInfo:0x000008036337c8             \
                 @filepath="/usr/local/lib/mecab/dic/ipadic/sys.dic", \
                 charset=utf8,                                        \
                 type=0>]                                             \
         @version=0.996>
    
    puts nm.version
    => 0.996 

----

Display details about the system dictionary used by MeCab:

    puts nm.libpath
    => /usr/local/lib/libmecab.so 

    sysdic = nm.dicts.first
    puts sysdic.filepath
    => /usr/local/lib/mecab/dic/ipadic/sys.dic

    puts sysdic.charset
    => utf8 
 
----

Parse Japanese text and send the MeCab result as a single string to stdout:

    puts nm.parse('俺の名前は星野豊だ！！そこんとこヨロシク！')
    俺      名詞,代名詞,一般,*,*,*,俺,オレ,オレ
    の      助詞,連体化,*,*,*,*,の,ノ,ノ
    名前    名詞,一般,*,*,*,*,名前,ナマエ,ナマエ
    は      助詞,係助詞,*,*,*,*,は,ハ,ワ
    星野    名詞,固有名詞,人名,姓,*,*,星野,ホシノ,ホシノ
    豊      名詞,固有名詞,人名,名,*,*,豊,ユタカ,ユタカ
    だ      助動詞,*,*,*,特殊・ダ,基本形,だ,ダ,ダ
    ！      記号,一般,*,*,*,*,！,！,！
    ！      記号,一般,*,*,*,*,！,！,！
    そこ    名詞,代名詞,一般,*,*,*,そこ,ソコ,ソコ
    ん      助詞,特殊,*,*,*,*,ん,ン,ン
    とこ    名詞,一般,*,*,*,*,とこ,トコ,トコ
    ヨロシク        感動詞,*,*,*,*,*,ヨロシク,ヨロシク,ヨロシク
    ！      記号,一般,*,*,*,*,！,！,！
    EOS

----

If a block is passed to `parse`, you can iterate over the list of resulting `MeCabNode`
instances to access more detailed information about each morpheme. 

In this example, the following attributes and methods for `MeCabNode` are used:

- `surface` - the morpheme surface
- `posid` - node part-of-speech ID (dictionary-dependent)
- `is_eos?` - is this `MeCabNode` an end-of-sentence node?

This iterates over the morpheme nodes in the given text,
and outputs a formatted, tab-delimited line with the
morpheme surface and part-of-speech ID, ignoring any end-of-sentence
nodes:

    nm.parse('世界チャンプ目指してんだなこれがっ!!夢なの、俺のっ!!') do |n|
      puts "#{n.surface}\tpart-of-speech id: #{n.posid}" if !n.is_eos?
    end
    世界    part-of-speech id: 38
    チャンプ        part-of-speech id: 38
    目指し  part-of-speech id: 31
    て      part-of-speech id: 18
    ん      part-of-speech id: 63
    だ      part-of-speech id: 25
    な      part-of-speech id: 17
    これ    part-of-speech id: 59
    がっ    part-of-speech id: 32
    !!      part-of-speech id: 36
    夢      part-of-speech id: 38
    な      part-of-speech id: 25
    の      part-of-speech id: 17
    、      part-of-speech id: 9
    俺      part-of-speech id: 59
    のっ    part-of-speech id: 31
    !!      part-of-speech id: 36

----

For more complex parsing, such as that for natural language
processing tasks, it is far more efficient to use `enum_parse` to
obtain an [`Enumerator`](http://ruby-doc.org/core-2.2.1/Enumerator.html)
to iterate over the resulting `MeCabNode` instances. An `Enumerator`
yields each `MeCabNode` instance without first materializing all
instances at once, thus being more efficient.

This example uses the `-F` node-format option to customize
the resulting `MeCabNode` feature attribute to extract:

- `%m` - morpheme surface
- `%f[0]` - node part-of-speech
- `%f[7]` - reading

Note that we can move the `Enumerator` both forwards and backwards, rewind it
back to the beginning, and then iterate over it.

    nm = Natto::MeCab.new('-F%m\t%f[0]\t%f[7]')
    
    enum = nm.enum_parse('この星の一等賞になりたいの卓球で俺は、そんだけ！')
    => #<Enumerator: #<Enumerator::Generator:0x00000002ff3898>:each>
    
    enum.next
    => #<Natto::MeCabNode:0x000000032eed68 \
         @pointer=#<FFI::Pointer address=0x000000005ffb48>, \
         stat=0, \
         @surface="この", \
         @feature="この   連体詞  コノ">
    
    enum.peek
    => #<Natto::MeCabNode:0x00000002fe2110a \
         @pointer=#<FFI::Pointer address=0x000000005ffdb8>, \
         stat=0, \
         @surface="星", \
         @feature="星       名詞    ホシ"> 
        
    enum.rewind
    
    # again, ignore any end-of-sentence nodes
    enum.each { |n| puts n.feature if !n.is_eos? }
    この    連体詞  コノ
    星      名詞    ホシ
    の      助詞    ノ
    一等    名詞    イットウ
    賞      名詞    ショウ
    に      助詞    ニ
    なり    動詞    ナリ
    たい    助動詞  タイ
    の      助詞    ノ
    卓球    名詞    タッキュウ
    で      助詞    デ
    俺      名詞    オレ
    は      助詞    ハ
    、      記号    、
    そん    名詞    ソン
    だけ    助詞    ダケ
    ！      記号    ！

----

[Partial parsing](http://taku910.github.io/mecab/partial.html) allows you to
pass hints to MeCab on how to tokenize morphemes when parsing. Most useful are
boundary constraint parsing and feature constraint parsing.

With boundary constraint parsing, you can specify either
a [Regexp](http://ruby-doc.org/core-2.2.1/Regexp.html) or
[String](http://ruby-doc.org/core-2.2.1/String.html) to tell MeCab where the
boundaries of a morpheme should be. Use the `boundary_constraints` keyword.
For hints on tokenization, please see
[String#scan](http://ruby-doc.org/core-2.2.1/String.html#method-i-scan)

This example uses the `-F` node-format option to customize
the resulting `MeCabNode` feature attribute to extract:

- `%m` - morpheme surface
- `%f[0]` - node part-of-speech
- `%s` - node `stat` status value, 1 is `unknown`

Note that any such morphemes captured will have node `stat` status of unknown.
Also note that MeCab will tag such nodes as a noun.

    nm = Natto::MeCab.new('-F%m,\s%f[0],\s%s')

    text = '心の中で3回唱え、 ヒーロー見参！ヒーロー見参！ヒーロー見参！'
    pattern = /ヒーロー見参/

    nm.enum_parse(text, boundary_constraints: pattern).each do |n|
      puts n.feature if !(n.is_bos? || n.is_eos?)
    end

    # desired morpheme boundary specified with Regexp /ヒーロー見参/
    心, 名詞, 0
    の, 助詞, 0
    中, 名詞, 0
    で, 助詞, 0
    3, 名詞, 1
    回, 名詞, 0
    唱え, 動詞, 0
    、, 記号, 0
    ヒーロー見参, 名詞, 1
    ！, 記号, 0
    ヒーロー見参, 名詞, 1
    ！, 記号, 0
    ヒーロー見参, 名詞, 1
    ！, 記号, 0

With feature constraint parsing, you can provide instructions to MeCab on
what feature to use for a matching morpheme. Use the `feature_constraints`
keyword to pass in a hash mapping a specific morpheme key (String)
to a corresponding feature (String).

    # we re-use nm and text from above

    nm.options
    => {:node_format=>"%m,\\s%f[0],\\s%s"}

    mapping = {"ヒーロー見参"=>"その他"}

    nm.enum_parse(text, feature_constraints: mapping).each do |n|
      puts n.feature if !(n.is_bos? || n.is_eos?)
    end

    # ヒーロー見参 will be treated as a single morpheme mapping to その他 
    心, 名詞, 0
    の, 助詞, 0
    中, 名詞, 0
    で, 助詞, 0
    3, 名詞, 1
    回, 名詞, 0
    唱え, 動詞, 0
    、, 記号, 0
    ヒーロー見参, その他, 1
    ！, 記号, 0
    ヒーロー見参, その他, 1
    ！, 記号, 0
    ヒーロー見参, その他, 1
    ！, 記号, 0


## Learn more 
- You can read more about natto on the [project Wiki](https://github.com/buruzaemon/natto/wiki).

## Contributing to natto
-  Use [git](http://git-scm.com/) and [check out the latest code at GitHub](https://github.com/buruzaemon/natto) to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
-  [Browse the issue tracker](https://github.com/buruzaemon/natto/issues) to make sure someone already hasn't requested it and/or contributed it.
-  Fork the project.
-  Start a feature/bugfix branch.
-  Commit and push until you are happy with your contribution.
-  Make sure to add tests for it. This is important so I don't break it in a future version unintentionally. I use [MiniTest::Unit](http://rubydoc.info/gems/minitest/MiniTest/Unit) as it is very natural and easy-to-use.
-  Please try not to mess with the Rakefile, CHANGELOG, or version. If you must have your own version, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Changelog
Please see the {file:CHANGELOG} for this gem's release history.

## Copyright
Copyright &copy; 2016, Brooke M. Fujita. All rights reserved. Please see the {file:LICENSE} file for further details.

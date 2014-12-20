# natto
A Tasty Ruby Binding with MeCab

## What is natto?
A gem leveraging FFI (foreign function interface), natto combines the
[Ruby programming language](http://www.ruby-lang.org/) with 
[MeCab](http://mecab.googlecode.com/svn/trunk/mecab/doc/index.html), the part-of-speech
and morphological analyzer for the Japanese language.

-  No compiler is necessary, as natto is _not_ a C extension.
-  It will run on CRuby (mri/yarv) and JRuby (jvm) equally well.
-  It will work with MeCab installations on Windows, Unix/Linux or Mac OS.
-  natto provides a naturally Ruby-esque interface to MeCab.

You can learn more about [natto at bitbucket](https://bitbucket.org/buruzaemon/natto/).


## Requirements
natto requires the following:

-  [MeCab _0.996_](http://code.google.com/p/mecab/downloads/list)
-  A system dictionary, like [mecab-ipadic](https://mecab.googlecode.com/files/mecab-ipadic-2.7.0-20070801.tar.gz) or [mecab-jumandic](https://mecab.googlecode.com/files/mecab-jumandic-5.1-20070304.tar.gz)
-  `libmecab-devel` if you are on Linux, since natto uses `mecab-config`
-  Ruby _1.9 or greater_
-  [ffi _1.9.0 or greater_](http://rubygems.org/gems/ffi)

## Installation on *nix and Mac OS
Install natto with the following gem command:

    gem install natto

This will automatically install the [ffi](http://rubygems.org/gems/ffi) rubygem, which natto uses to bind to the `mecab` library.

## Installation on Windows 
However, if you are using a CRuby on Windows, then you will first need to install the [RubyInstaller Development Kit (DevKit)](https://github.com/oneclick/rubyinstaller/wiki/Development-Kit), a MSYS/MinGW based toolkit that enables your Windows Ruby installation to build many of the native C/C++ extensions available, including ffi.

1. Download the latest release for RubyInstaller for Windows platforms and the corresponding DevKit from the [RubyInstaller for Windows downloads page](http://rubyinstaller.org/downloads/).
2. After installing RubyInstaller for Windows, double-click on the DevKit-tdm installer `.exe`, and expand the contents to an appropriate location, for example `C:\devkit`.
3. Open a command window under `C:\devkit`, and execute: `ruby dk.rb init`. This will locate all known ruby installations, and add them to `C:\devkit\config.yml`.
4. Next, execute: `ruby dk.rb install`, which will add the DevKit to all of the installed rubies listed in your `C:\devkit\config.yml`. Now you should be able to install and build the ffi rubygem correctly on your Windows-installed ruby. 
5. Install natto with: 

        gem install natto

6. If you are on a 64-bit Windows and you use a 64-bit Ruby or JRuby, then you might want to [build a 64-bit version of libmecab.dll](https://bitbucket.org/buruzaemon/natto/wiki/64-Bit-Windows).


## Configuration
-  ***No explicit configuration should be necessary, as natto will try to locate the `mecab` library based upon its runtime environment.***
    - On Windows, it will query the Windows Registry to determine where `libmecab.dll` is installed
    - On Mac OS and \*nix, it will query `mecab-config --libs` 
-   ***But if natto cannot find the `mecab` library, `LoadError` will be raised.***
    - Please set the `MECAB_PATH` environment variable to the exact name/path to your `mecab` library.
    - e.g., for Mac OS

            export MECAB_PATH=/usr/local/Cellar/mecab/0.996/lib/libmecab.dylib 

    - e.g., for bash on UNIX/Linux

            export MECAB_PATH=/usr/local/lib/libmecab.so

    - e.g., on Windows

            set MECAB_PATH=C:\Program Files\MeCab\bin\libmecab.dll

    - e.g., from within a Ruby program

            ENV['MECAB_PATH']='/usr/local/lib/libmecab.so'

## Usage


    # Quick Start
    # -----------
    #  
    # No explicit configuration should be necessary!
    #
    require 'natto'

    # first, create an instance of Natto::MeCab
    #
    nm = Natto::MeCab.new
    => #<Natto::MeCab:0x28d30748 
         @tagger=#<FFI::Pointer address=0x28a97d50>, \
         @libpath="/usr/local/lib/libmecab.so", \
         @options={}, \
         @dicts=[#<Natto::DictionaryInfo:0x28d3061c \
                 @filepath="/usr/local/lib/mecab/dic/ipadic/sys.dic", \
                 charset=utf8, \
                 type=0>] \
         @version=0.996>
    
    # display MeCab version
    #
    puts nm.version
    => 0.996 

    # display full pathname to MeCab library
    #
    puts nm.libpath
    => /usr/local/lib/libmecab.so 

    # reference to MeCab system dictionary
    #
    sysdic = nm.dicts.first

    # display full pathname to system dictionary file
    #
    puts sysdic.filepath
    => /usr/local/lib/mecab/dic/ipadic/sys.dic

    # what charset (encoding) is the system dictionary?
    #
    puts sysdic.charset
    => utf8 
  
    # parse text and send output to stdout
    #
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

    # parse more text and use a block to:
    # - iterate the resulting MeCab nodes
    # - output morpheme surface and part-of-speech ID
    #
    # * ignore any end-of-sentence nodes
    #
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

    # for more complex parsing, such as that for natural 
    # language processing tasks, it is far more efficient
    # to iterate over MeCab nodes using an Enumerator
    # 
    # this example uses the node-format option to customize
    # the resulting morpheme feature to extract:
    # - surface
    # - part-of-speech
    # - reading
    #
    # * again, ignore any end-of-sentence nodes
    #
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

    enum.each { |n| puts n.feature }
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

   

## Learn more 
- You can read more about natto on the [project Wiki](https://bitbucket.org/buruzaemon/natto/wiki/Home).

## Contributing to natto
-  Use [mercurial](http://mercurial.selenic.com/) and [check out the latest code at bitbucket](https://bitbucket.org/buruzaemon/natto/src/) to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
-  [Browse the issue tracker](https://bitbucket.org/buruzaemon/natto/issues/) to make sure someone already hasn't requested it and/or contributed it.
-  Fork the project.
-  Start a feature/bugfix branch.
-  Commit and push until you are happy with your contribution.
-  Make sure to add tests for it. This is important so I don't break it in a future version unintentionally. I use [MiniTest::Unit](http://rubydoc.info/gems/minitest/MiniTest/Unit) as it is very natural and easy-to-use.
-  Please try not to mess with the Rakefile, CHANGELOG, or version. If you must have your own version, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Changelog
Please see the {file:CHANGELOG} for this gem's release history.

## Copyright
Copyright &copy; 2014-2015, Brooke M. Fujita. All rights reserved. Please see the {file:LICENSE} file for further details.

# natto
A Tasty Ruby Binding with MeCab

## What is natto?
natto combines the [Ruby programming language](http://www.ruby-lang.org/) with [MeCab](http://mecab.googlecode.com/svn/trunk/mecab/doc/index.html), the part-of-speech and morphological analyzer for the Japanese language.

natto is a gem bridging Ruby and MeCab using FFI (foreign function interface). No compilation is necessary, as natto is _not_ a C extension. natto will run on CRuby (mri/yarv) and JRuby (jvm) equally well. natto will also run on Windows, Unix/Linux, and Mac.

You can learn more about [natto at bitbucket](https://bitbucket.org/buruzaemon/natto/).

## Requirements
natto requires the following:

-  [MeCab _0.993_](http://code.google.com/p/mecab/downloads/list)
-  [ffi _0.6.3 or greater_](http://rubygems.org/gems/ffi)
-  Ruby _1.8.7 or greater_

## Installation on *NIX/Mac/Cygwin
Install natto with the following gem command:

    gem install natto

This will automatically install the [ffi](http://rubygems.org/gems/ffi) rubygem, which is what natto uses to bind to the <tt>mecab</tt> library.

## Installation on Windows 
However, if you are using a CRuby on Windows, then you will first need to install the [RubyInstaller Development Kit (DevKit)](https://github.com/oneclick/rubyinstaller/wiki/Development-Kit), which is a MSYS/MinGW based toolkit than enables your Windows Ruby installation to build many of the native C/C++ extensions available, including <tt>ffi</tt>.

1. Download the latest release for RubyInstaller for Windows platforms and the corresponding DevKit from the [RubyInstaller for Windows downloads page](http://rubyinstaller.org/downloads/).
2. After installing RubyInstaller for Windows, double-click on the DevKit-tdm installer <tt>.exe</tt>, and expand the contents to an appropriate location, for example <tt>C:\devkit</tt>.
3. Open a command window under <tt>C:\devkit</tt>, and execute: <tt>ruby dk.rb init</tt>. This will locate all known ruby installations, and add them to <tt>C:\devkit\config.yml</tt>.
4. Next, execute: <tt>ruby dk.rb install</tt>, which will add the DevKit to all of the installed rubies listed in your <tt>C:\devkit\config.yml</tt>.
5. Now you should be able to install and build the <tt>ffi</tt> rubygem correctly on your Windows-installed ruby, so you can install <tt>natto with</tt>: 

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
         @tagger=#<FFI::Pointer address=0x28a97d50>, \
         @options={}, \
         @dicts=[#<Natto::DictionaryInfo:0x28d3061c \
                 type="0", \
                 filename="/usr/local/lib/mecab/dic/ipadic/sys.dic", \
                 charset="utf8">], \
         @version="0.993">

    puts nm.version
    => "0.993" 

    sysdic = nm.dicts.first

    puts sysdic.filename
    => "/usr/local/lib/mecab/dic/ipadic/sys.dic"

    puts sysdic.charset
    => "utf8" 
    
    nm.parse('ピンチの時には必ずヒーローが現れる。') do |n|
      puts "#{n.surface}\t#{n.feature}"
    end
    ピンチ      名詞,一般,*,*,*,*,ピンチ,ピンチ,ピンチ
    の          助詞,連体化,*,*,*,*,の,ノ,ノ
    時          名詞,非自立,副詞可能,*,*,*,時,トキ,トキ 
    に          助詞,格助詞,一般,*,*,*,に,一般ニ,ニ
    は          助詞,係助詞,*,*,*,*,は,ハ,ワ
    必ず        副詞,助詞類接続,*,*,*,*,必ず,カナラズ,カナラズ
    ヒーロー    名詞,一般,*,*,*,*,ヒーロー,ヒーローー,ヒーロー
    が          助詞,格助詞,一般,*,*,*,が,ガ,ガ
    現れる      動詞,自立,*,*,一段,基本形,現れる,アラワレル,アラワレル
    。          記号,句点,*,*,*,*,。,。,。句点
                BOS/EOS,*,*,*,*,*,*,*,*


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

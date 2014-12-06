# natto
A Tasty Ruby Binding with MeCab

## What is natto?
A package leveraging FFI (foreign function interface), `natto` combines the
[Ruby programming language](http://www.ruby-lang.org/) with 
[MeCab](http://mecab.googlecode.com/svn/trunk/mecab/doc/index.html), the part-of-speech
and morphological analyzer for the Japanese language.

-  No compilation is necessary, as `natto` is _not_ a C extension.
-  It will run on CRuby (mri/yarv) and JRuby (jvm) equally well.
-  It will also run on Windows, Unix/Linux, and Mac.

You can learn more about [natto at bitbucket](https://bitbucket.org/buruzaemon/natto/).


## Requirements
`natto` requires the following:

-  [MeCab _0.996_](http://code.google.com/p/mecab/downloads/list)
-  A system dictionary, like [mecab-ipadic](https://mecab.googlecode.com/files/mecab-ipadic-2.7.0-20070801.tar.gz) or [mecab-jumandic](https://mecab.googlecode.com/files/mecab-jumandic-5.1-20070304.tar.gz)
-  `libmecab-devel` if you are on Linux, since `natto` uses `mecab-config`

        $ sudo apt-get install libmecab-dev

-  [ffi _1.9.0 or greater_](http://rubygems.org/gems/ffi)
-  Ruby _1.9 or greater_

## Installation on *NIX/Mac
Install `natto` with the following gem command:

    gem install natto

This will automatically install the [ffi](http://rubygems.org/gems/ffi) rubygem, which `natto` uses to bind to the `mecab` library.

## Installation on Windows 
However, if you are using a CRuby on Windows, then you will first need to install the [RubyInstaller Development Kit (DevKit)](https://github.com/oneclick/rubyinstaller/wiki/Development-Kit), a MSYS/MinGW based toolkit that enables your Windows Ruby installation to build many of the native C/C++ extensions available, including `ffi`.

1. Download the latest release for RubyInstaller for Windows platforms and the corresponding DevKit from the [RubyInstaller for Windows downloads page](http://rubyinstaller.org/downloads/).
2. After installing RubyInstaller for Windows, double-click on the DevKit-tdm installer `.exe`, and expand the contents to an appropriate location, for example `C:\devkit`.
3. Open a command window under `C:\devkit`, and execute: `ruby dk.rb init`. This will locate all known ruby installations, and add them to `C:\devkit\config.yml`.
4. Next, execute: `ruby dk.rb install`, which will add the DevKit to all of the installed rubies listed in your `C:\devkit\config.yml`. Now you should be able to install and build the `ffi` rubygem correctly on your Windows-installed ruby. 
5. Install `natto` with: 

        gem install natto

6. If you are on a 64-bit Windows and you use a 64-bit Ruby or JRuby, then you might want to [build a 64-bit version of libmecab.dll](https://bitbucket.org/buruzaemon/natto/wiki/64-Bit-Windows).


## Configuration
-  No explicit configuration should be necessary!
-  `natto` will try to locate the `mecab` library based upon its runtime environment.
    - On Windows, it will query the Windows Registry to determine where `libmecab.dll` is installed
    - On Mac OS and \*nix, it will query `mecab-config --libs` 
-  If `natto` cannot find the mecab library, a `LoadError` will be raised. Please set the `MECAB_PATH` environment variable to the exact name/path to your `mecab` library.
    - e.g., for Mac OS X

            export MECAB_PATH=/usr/local/Cellar/mecab/0.996/lib/libmecab.dylib 

    - e.g., for bash on UNIX/Linux

            export MECAB_PATH=/usr/local/lib/libmecab.so

    - e.g., on Windows

            set MECAB_PATH=C:\Program Files\MeCab\bin\libmecab.dll

    - e.g., from within a Ruby program

            ENV['MECAB_PATH']='/usr/local/lib/libmecab.so'

## Usage
    require 'natto'

    nm = Natto::MeCab.new
    => #<Natto::MeCab:0x28d30748 
         @tagger=#<FFI::Pointer address=0x28a97d50>, \
         @options={}, \
         @dicts=[#<Natto::DictionaryInfo:0x28d3061c \
                 type="0", \
                 filename="/usr/local/lib/mecab/dic/ipadic/sys.dic", \
                 charset="utf8">], \
         @version="0.996">

    puts nm.version
    => "0.996" 

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
    。         記号,句点,*,*,*,*,。,。,。句点
               BOS/EOS,*,*,*,*,*,*,*,*


## Learn more 
- You can read more about `natto` on the [project Wiki](https://bitbucket.org/buruzaemon/natto/wiki/Home).

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
Copyright &copy; 2011, Brooke M. Fujita. All rights reserved. Please see the {file:LICENSE} file for further details.
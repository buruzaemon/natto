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
    require 'natto'

    m = Natto::MeCab.new
    puts m.parse("すもももももももものうち")
    すもも  名詞,一般,*,*,*,*,すもも,スモモ,スモモ
    も      助詞,係助詞,*,*,*,*,も,モ,モ
    もも    名詞,一般,*,*,*,*,もも,モモ,モモ
    も      助詞,係助詞,*,*,*,*,も,モ,モ
    もも    名詞,一般,*,*,*,*,もも,モモ,モモ
    の      助詞,連体化,*,*,*,*,の,ノ,ノ
    うち    名詞,非自立,副詞可能,*,*,*,うち,ウチ,ウチ
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

- __2010/12/30: 0.0.7 release.
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

natto &copy; 2010-2013 by Brooke M. Fujita, licensed under the new BSD license. Please see the [LICENSE](file.LICENSE.html) document for further details.

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
#     require 'natto'
#
#     m = Natto::MeCab.new
#     puts m.parse("すもももももももものうち")
#     すもも  名詞,一般,*,*,*,*,すもも,スモモ,スモモ
#     も      助詞,係助詞,*,*,*,*,も,モ,モ
#     もも    名詞,一般,*,*,*,*,もも,モモ,モモ
#     も      助詞,係助詞,*,*,*,*,も,モ,モ
#     もも    名詞,一般,*,*,*,*,もも,モモ,モモ
#     の      助詞,連体化,*,*,*,*,の,ノ,ノ
#     うち    名詞,非自立,副詞可能,*,*,*,うち,ウチ,ウチ
#     EOS
#     => nil
#
module Natto

  # Module <tt>Binding</tt> encapsulates methods and behavior 
  # which are made available via <tt>FFI</tt> bindings to 
  # <tt>mecab</tt>.
  module Binding
    require 'ffi'
    require 'rbconfig'
    extend FFI::Library

    # String name for the environment variable used by 
    # <tt>Natto</tt> to indicate the exact name / full path
    # to the <tt>mecab</tt> library.
    MECAB_PATH = 'MECAB_PATH'
    
    # @private
    def self.included(base)
      base.extend(ClassMethods)
    end

    # Returns the name of the <tt>mecab</tt> library based on 
    # the runtime environment. The value of the environment
    # parameter <tt>MECAB_PATH</tt> is checked before this
    # function is invoked, and in the case of Windows, a
    # <tt>LoadError</tt> will be raised if <tt>MECAB_PATH</tt>
    # is <b>not</b> set to the full path of the <tt>mecab</tt>
    # library.
    # @return name of the <tt>mecab</tt> library
    # @raise [LoadError] if MECAB_PATH environment variable is not set in Windows
    # <br/>
    # e.g., for bash on UNIX/Linux
    #     export MECAB_PATH=mecab.so
    # e.g., on Windows
    #     set MECAB_PATH=C:\Program Files\MeCab\bin\libmecab.dll
    # e.g., for Cygwin
    #     export MECAB_PATH=cygmecab-1
    def self.find_library
      host_os = RbConfig::CONFIG['host_os']

      if host_os =~ /mswin|mingw/i
        raise LoadError, "Please set #{MECAB_PATH} to full path to libmecab.dll"
      elsif host_os =~ /cygwin/i
        'cygmecab-1'
      else
        'mecab'
      end
    end

    ffi_lib(ENV[MECAB_PATH] || find_library)

    attach_function :mecab_version, [], :string
    attach_function :mecab_new2, [:string], :pointer
    attach_function :mecab_destroy, [:pointer], :void
    attach_function :mecab_sparse_tostr, [:pointer, :string], :string
    attach_function :mecab_strerror, [:pointer],:string
    attach_function :mecab_dictionary_info, [:pointer], :pointer

    # @private
    module ClassMethods
      def mecab_version
        Natto::Binding.mecab_version
      end
    end
  end
end

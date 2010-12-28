# -*- coding: UTF-8 -*-
require 'rubygems' if RUBY_VERSION.to_f < 1.9

# natto combines the Ruby programming language with MeCab, 
# the part-of-speech and morphological analyzer for the
# Japanese language.
# 
# === Requirements
# natto requires the following:
# * {http://sourceforge.net/projects/mecab/files/mecab/ MeCab 0.98}
# * {http://rubygems.org/gems/ffi ffi 0.63 or greater}
# * Ruby 1.8.7 or greater
#
# === Installation
# Install natto with the following gem command:
# * <code>gem install natto</code>
#
# === Configuration
# * natto will try to locate the <tt>mecab</tt> library based upon its runtime environment.
# * In case of <tt>LoadError</tt>, please set the <tt>MECAB_PATH</tt> environment variable to the exact name/path to your <tt>mecab</tt> library.
#
#== Usage
#  require 'natto'
#
#  m = Natto::MeCab.new
#  puts m.parse("すもももももももものうち")
#  すもも  名詞,一般,*,*,*,*,すもも,スモモ,スモモ
#  も      助詞,係助詞,*,*,*,*,も,モ,モ
#  もも    名詞,一般,*,*,*,*,もも,モモ,モモ
#  も      助詞,係助詞,*,*,*,*,も,モ,モ
#  もも    名詞,一般,*,*,*,*,もも,モモ,モモ
#  の      助詞,連体化,*,*,*,*,の,ノ,ノ
#  うち    名詞,非自立,副詞可能,*,*,*,うち,ウチ,ウチ
#  EOS
#  => nil
#
# @author Brooke M. Fujita (buruzaemon)
module Natto 
  require 'ffi'

  # <tt>MeCab</tt> is a wrapper class to the <tt>mecab</tt> parser.
  # Options to the <tt>mecab</tt> parser are passed in as a hash to
  # #initialize.
  # 
  # @see {SUPPORTED_OPTS}
  class MeCab
    # Supported options to the <tt>mecab</tt> parser.
    # See the <tt>mecab</tt> help for more details. 
    SUPPORTED_OPTS = [ :rcfile, :dicdir, :userdic, :output_format_type, :lattice_level, 
                       :node_format, :unk_format, :bos_format, :eos_format, :eon_format,
                       :unk_feature, :nbest, :theta, :cost_factor ].freeze
                       # :all_morphs, :partial, :allocate_sentence ]

    # Initialize the wrapped <tt>mecab</tt> instance, with the
    # given <tt>options</tt> hash.
    # <br/>
    # Options supported are:
    # * :rcfile -- resource file
    # * :dicdir -- system dicdir
    # * :userdic -- user dictionary
    # * :lattice_level -- lattice information level (integer, default 0)
    # * :output_format_type -- output format type (wakati, chasen, yomi, etc.)
    # * :node_format -- user-defined node format
    # * :unk_format -- user-defined unknown node format
    # * :bos_format -- user-defined beginning-of-sentence format
    # * :eos_format -- user-defined end-of-sentence format
    # * :eon_format -- user-defined end-of-NBest format
    # * :unk_feature -- feature for unknown word
    # * :nbest --  output N best results (integer, default 1)
    # * :theta -- temperature parameter theta (float, default 0.75)
    # * :cost_factor -- cost factor (integer, default 700)
    # <br/>
    # Use single-quotes to preserve format options that contain escape chars.
    # <br/>
    # e.g.
    #   m = Natto::MeCab.new(:node_format=>'%m\t%f[7]\n')
    #
    # @param [Hash]
    # @see {SUPPORTED_OPTS}
    def initialize(options={})
      opt_str = self.class.build_options_str(options)
      @ptr = Natto::Binding.mecab_new2(opt_str)
      raise MeCabError.new("Could not initialize MeCab with options: '#{opt_str}'") if @ptr.address == 0
      #@dict = Natto::DictionaryInfo.new(Natto::Binding.mecab_dictionary_info(@ptr))
      ObjectSpace.define_finalizer(self, self.class.create_free_proc(@ptr))
    end

    # Parses the given string <tt>s</tt>.
    #
    # @param [String]
    def parse(s)
      Natto::Binding.mecab_sparse_tostr(@ptr, s) || 
        raise(MeCabError.new(Natto::Binding.mecab_strerror(@ptr)))
    end


    # Returns a <tt>Proc</tt> that is registered to be invoked
    # after the object owning <tt>ptr</tt> has been destroyed.
    #
    # @param [FFI::MemoryPointer] ptr
    def self.create_free_proc(ptr)
      Proc.new do
        Natto::Binding.mecab_destroy(ptr)
      end
    end

    # Returns a string-representation of the options to
    # be passed in the construction of <tt>mecab</tt>.
    #
    # @param [Hash] options 
    def self.build_options_str(options={})
      opt = []
      SUPPORTED_OPTS.each do |k|
        if options.has_key? k
          key = k.to_s.gsub('_', '-')  
          opt << "--#{key}=#{options[k]}"

          #if key.end_with? '_format_' or key.end_with? '_feature'
          #  opt << "--#{key}="+options[k]
          #else
          #  opt << "--#{key}=#{options[k]}"
          #end
        end
      end
      opt.join(" ")
    end
  end

  # <tt>MeCabError</tt> is a general error class 
  # for the <tt>Natto</tt> module.
  class MeCabError < RuntimeError; end

  # <tt>DictionaryInfo</tt> is a wrapper for a <tt>MeCab</tt>
  # instance's related dictionary information.
  # <br>
  # Values may be obtained by using the following symbols 
  # as keys to the hash of <tt>mecab</tt> dictionary information.
  # * :filename
  # * :charset
  # * :size
  # * :type
  # * :lsize
  # * :rsize
  # * :version
  # * :next
  # <br>
  # Usage:
  #  dict = Natto::DictionaryInfo.new(mecab_ptr)
  #  puts dict[:filename]
  #  =>  /usr/local/lib/mecab/dic/ipadic/sys.dic
  #  puts dict[:charset]
  #  =>  utf8
  class DictionaryInfo < FFI::Struct
    layout  :filename, :string,
            :charset,  :string,
            :size,     :uint,
            :type,     :int,
            :lsize,    :uint,
            :rsize,    :uint,
            :version,  :ushort,
            :next,     :pointer 
  end

  # Module <tt>Binding</tt> encapsulates operations which are
  # made available via <tt>FFI</tt> bindings to <tt>mecab</tt>
  module Binding
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

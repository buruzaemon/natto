# coding: utf-8
require 'rubygems' if RUBY_VERSION.to_f < 1.9
require 'natto/binding'

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
# hi すもも  名詞,一般,*,*,*,*,すもも,スモモ,スモモ
#     &amp;#x65e5;
#
module Natto 
  require 'ffi'

  # <tt>MeCab</tt> is a wrapper class for the <tt>mecab</tt> parser.
  # Options to the <tt>mecab</tt> parser are passed in as a hash at
  # initialization.
  #
  # ## Usage
  #     require 'natto'
  #
  #     m = Natto::MeCab.new
  #     puts m.parse("すもももももももものうち")
  #     => すもも  名詞,一般,*,*,*,*,すもも,スモモ,スモモ
  #     => も      助詞,係助詞,*,*,*,*,も,モ,モ
  #     => もも    名詞,一般,*,*,*,*,もも,モモ,モモ
  #     => も      助詞,係助詞,*,*,*,*,も,モ,モ
  #     => もも    名詞,一般,*,*,*,*,もも,モモ,モモ
  #     => の      助詞,連体化,*,*,*,*,の,ノ,ノ
  #     => うち    名詞,非自立,副詞可能,*,*,*,うち,ウチ,ウチ
  #     => EOS
  #     => nil
  # 
  class MeCab

    attr_reader :options

    # Supported options to the <tt>mecab</tt> parser.
    # See the <tt>mecab</tt> help for more details. 
    SUPPORTED_OPTS = [  :rcfile, :dicdir, :userdic, :lattice_level, :all_morphs,
                        :output_format_type, :partial, :node_format, :unk_format, 
                        :bos_format, :eos_format, :eon_format, :unk_feature, 
                        :nbest, :theta, :cost_factor ].freeze
                        # :allocate_sentence ]

    #OPTION_DEFAULTS = { :lattice_level=>0, :all_morphs=>false, :nbest=>1, 
    #                    :theta=>0.75, :cost_factor=>700 }.freeze

    # Initializes the wrapped <tt>mecab</tt> instance with the
    # given <tt>options</tt> hash.
    # 
    # Options supported are:
    #
    # - :rcfile --  resource file
    # - :dicdir --  system dicdir
    # - :userdic --  user dictionary
    # - :lattice_level --  lattice information level (integer, default 0)
    # - :all_morphs --  output all morphs (default false)
    # - :output_format_type --  output format type (wakati, chasen, yomi, etc.)
    # - :partial --  partial parsing mode
    # - :node_format --  user-defined node format
    # - :unk_format --  user-defined unknown node format
    # - :bos_format --  user-defined beginning-of-sentence format
    # - :eos_format --  user-defined end-of-sentence format
    # - :eon_format --  user-defined end-of-NBest format
    # - :unk_feature --  feature for unknown word
    # - :nbest --  output N best results (integer, default 1)
    # - :theta --  temperature parameter theta (float, default 0.75)
    # - :cost_factor --  cost factor (integer, default 700)
    # 
    # _Use single-quotes to preserve format options that contain escape chars._
    # 
    # e.g.
    #     m = Natto::MeCab.new(:node_format=>'%m\t%f[7]\n')
    #     puts m.parse("日本語は難しいです。")
    #     日本語  ニホンゴ
    #     は      ハ
    #     難しい  ムズカシイ
    #     です    デス
    #     。      。
    #     EOS
    #     => nil
    #
    # @param [Hash]
    # @raise [MeCabError] if <tt>mecab</tt> cannot be initialized with the given <tt>options</tt>
    # @see MeCab::SUPPORTED_OPTS
    def initialize(options={})
      @options = options
      opt_str = self.class.build_options_str(@options)
      @ptr = Natto::Binding.mecab_new2(opt_str)
      raise MeCabError.new("Could not initialize MeCab with options: '#{opt_str}'") if @ptr.address == 0
      #@dict = Natto::DictionaryInfo.new(Natto::Binding.mecab_dictionary_info(@ptr))
      ObjectSpace.define_finalizer(self, self.class.create_free_proc(@ptr))
    end

    # Parses the given string <tt>s</tt>.
    #
    # @param [String] s
    # @return parsing result from <tt>mecab</tt>
    # @raise [MeCabError] if the <tt>mecab</tt> parser cannot parse the given string <tt>s</tt>
    def parse(s)
      Natto::Binding.mecab_sparse_tostr(@ptr, s) || 
        raise(MeCabError.new(Natto::Binding.mecab_strerror(@ptr)))
    end


    # Returns a <tt>Proc</tt> that is registered to be invoked
    # after the object owning <tt>ptr</tt> has been destroyed.
    #
    # @param [FFI::MemoryPointer] ptr
    # @return [Proc] to release <tt>mecab</tt> resources properly
    def self.create_free_proc(ptr)
      Proc.new do
        Natto::Binding.mecab_destroy(ptr)
      end
    end

    # Returns a string-representation of the options to
    # be passed in the construction of <tt>mecab</tt>.
    #
    # @param [Hash] options 
    # @return string-representation of the options to the <tt>mecab</tt> parser
    def self.build_options_str(options={})
      opt = []
      SUPPORTED_OPTS.each do |k|
        if options.has_key? k
          key = k.to_s.gsub('_', '-')  
          if %w( all-morphs partial ).include? key
            opt << "--#{key}" if options[k]==true
          else
            opt << "--#{key}=#{options[k]}"
          end

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
  # 
  # Values may be obtained by using the following symbols 
  # as keys to the hash of <tt>mecab</tt> dictionary information.
  #
  # - :filename
  # - :charset
  # - :size
  # - :type
  # - :lsize
  # - :rsize
  # - :version
  # - :next
  # 
  # # Usage:
  #
  #     dict = Natto::DictionaryInfo.new(mecab_ptr)
  #     puts dict[:filename]
  #     =>  /usr/local/lib/mecab/dic/ipadic/sys.dic
  #     puts dict[:charset]
  #     =>  utf8
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
end

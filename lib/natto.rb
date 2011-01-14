# coding: utf-8
require 'rubygems' if RUBY_VERSION.to_f < 1.9
require 'natto/binding'

module Natto 
  require 'ffi'

  # <tt>MeCab</tt> is a wrapper class for the <tt>mecab</tt> parser.
  # Options to the <tt>mecab</tt> parser are passed in as a hash at
  # initialization.
  #
  # ## Usage
  # _Here is how to use natto under Ruby 1.9:_
  #     require 'natto'
  #
  #     m = Natto::MeCab.new
  #     => #<Natto::MeCab:0x28d93dd4 @options={}, \
  #                                  @dicts=[#<Natto::DictionaryInfo:0x28d93d34>], \
  #                                  @ptr=#<FFI::Pointer address=0x28af3e58>>
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
  class MeCab

    attr_reader :options, :dicts

    # Supported options to the <tt>mecab</tt> parser.
    # See the <tt>mecab</tt> help for more details. 
    SUPPORTED_OPTS = [  :rcfile, :dicdir, :userdic, :lattice_level, :all_morphs,
                        :output_format_type, :partial, :node_format, :unk_format, 
                        :bos_format, :eos_format, :eon_format, :unk_feature, 
                        :nbest, :theta, :cost_factor ].freeze

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
    #     => #<Natto::MeCab:0x28d8886c @options={:node_format=>"%m\\t%f[7]\\n"}, \
    #                                     @dicts=[#<Natto::DictionaryInfo:0x28d8863c>], \
    #                                     @ptr=#<FFI::Pointer address=0x28e3b268>>
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
      @dicts = []

      opt_str = self.class.build_options_str(@options)
      @ptr = Natto::Binding.mecab_new2(opt_str)
      raise MeCabError.new("Could not initialize MeCab with options: '#{opt_str}'") if @ptr.address == 0x0

      @dicts << Natto::DictionaryInfo.new(Natto::Binding.mecab_dictionary_info(@ptr))
      while @dicts.last[:next].address != 0x0
        @dicts << Natto::DictionaryInfo.new(@dicts.last[:next])
      end

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

    # Returns the <tt>mecab</tt> version.
    # @return the <tt>mecab</tt> version.
    def version
      Natto::Binding.mecab_version
    end

    # Returns a <tt>Proc</tt> that is registered to be invoked
    # after the object owning <tt>ptr</tt> has been destroyed.
    #
    # @param [FFI::Pointer] ptr
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
  #     m = Natto::MeCab.new
  #     sysdic = m.dicts.first
  #     puts sysdic[:filename]
  #     =>  /usr/local/lib/mecab/dic/ipadic/sys.dic
  #     puts sysdic[:charset]
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

# coding: utf-8
require 'natto/binding'
require 'natto/option_parse'
require 'natto/utils'

module Natto 
  require 'ffi'

  # <tt>MeCabStruct</tt> is a general base class 
  # for <tt>FFI::Struct</tt> objects in the <tt>Natto</tt> module.
  class MeCabStruct < FFI::Struct
    # Provides accessor methods for the members of the <tt>mecab</tt> struct.
    #
    # @param [String] attr_name
    # @return member values for the <tt>mecab</tt> struct
    # @raise [NoMethodError] if <tt>attr_name</tt> is not a member of this <tt>mecab</tt> struct 
    def method_missing(attr_name)
      member_sym = attr_name.id2name.to_sym
      return self[member_sym] if self.members.include?(member_sym)
      raise(NoMethodError.new("undefined method '#{attr_name}' for #{self}"))
    end
  end

  # <tt>DictionaryInfo</tt> is a wrapper for the structure holding
  # the <tt>MeCab</tt> instance's related dictionary information.
  # 
  # Values for the <tt>mecab</tt> dictionary attributes may be 
  # obtained by using the following <tt>Symbol</tt>s as keys 
  # to the layout associative array of <tt>FFI::Struct</tt> members.
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
  # <h2>Usage</h2>
  # <tt>mecab</tt> dictionary attributes can be obtained by
  # using their corresponding accessor.
  #
  #     nm = Natto::MeCab.new
  #
  #     sysdic = nm.dicts.first
  #
  #     puts sysdic.filename
  #     => "/usr/local/lib/mecab/dic/ipadic/sys.dic"
  #
  #     puts sysdic.charset
  #     => "utf8"
  # 
  #     puts sysdic.is_sysdic?
  #     => true
  class DictionaryInfo < MeCabStruct
    # System dictionary.
    SYS_DIC = 0
    # User dictionary.
    USR_DIC = 1
    # Unknown dictionary.
    UNK_DIC = 2

    layout  :filename, :string,
            :charset,  :string,
            :size,     :uint,
            :type,     :int,
            :lsize,    :uint,
            :rsize,    :uint,
            :version,  :ushort,
            :next,     :pointer
   
    if Object.respond_to?(:type) && Object.respond_to?(:class)
      alias_method :deprecated_type, :type
      # <tt>Object#type</tt> override defined when both <tt>type</tt> and
      # <tt>class</tt> are Object methods. This is a hack to avoid the 
      # <tt>Object#type</tt> deprecation warning thrown up in Ruby 1.8.7
      # and in JRuby.
      #
      # @return [Fixnum] <tt>mecab</tt> dictionary type
      def type
        self[:type]
      end
    end

    # Returns human-readable details for this <tt>mecab</tt> dictionary.
    # Overrides <tt>Object#to_s</tt>.
    #
    # - encoded object id
    # - dictionary type
    # - full-path dictionary filename
    # - dictionary charset
    #
    # @return [String] encoded object id, type, dictionary filename, and charset
    def to_s
      %(#{super.chop} type="#{self.type}", filename="#{self.filename}", charset="#{self.charset}">)
    end
    
    # Overrides <tt>Object#inspect</tt>.
    #
    # @return [String] encoded object id, dictionary filename, and charset
    # @see #to_s
    def inspect
      self.to_s
    end

    # Returns <tt>true</tt> if this is a system dictionary.
    # @return [Boolean]
    def is_sysdic?
      self.type == SYS_DIC
    end

    # Returns <tt>true</tt> if this is a user dictionary.
    # @return [Boolean]
    def is_usrdic?
      self.type == USR_DIC
    end

    # Returns <tt>true</tt> if this is a unknown dictionary type.
    # @return [Boolean]
    def is_unkdic?
      self.type == UNK_DIC
    end
  end

  # <tt>MeCabNode</tt> is a wrapper for the structure holding
  # the parsed <tt>node</tt>.
  # 
  # Values for the <tt>mecab</tt> node attributes may be 
  # obtained by using the following <tt>Symbol</tt>s as keys 
  # to the layout associative array of <tt>FFI::Struct</tt> members.
  #
  # - :prev
  # - :next
  # - :enext
  # - :bnext
  # - :rpath
  # - :lpath
  # - :surface
  # - :feature
  # - :id
  # - :length
  # - :rlength
  # - :rcAttr
  # - :lcAttr
  # - :posid
  # - :char_type
  # - :stat
  # - :isbest
  # - :alpha
  # - :beta
  # - :prob
  # - :wcost
  # - :cost
  #
  # <h2>Usage</h2>
  # An instance of <tt>MeCabNode</tt> is yielded to the block
  # used with <tt>MeCab#parse</tt>, where the above-mentioned
  # node attributes may be accessed by name.
  #
  #     nm = Natto::MeCab.new
  #
  #     nm.parse('卓球なんて死ぬまでの暇つぶしだよ。') do |n| 
  #       puts "#{n.surface}\t#{n.cost}" if n.is_nor? 
  #     end
  #     卓球     2874
  #     な       4398
  #     死ぬ     9261
  #     まで     9386
  #     の       10007
  #     暇つぶし 13324
  #     だ       15346
  #     よ       14396
  #     。       10194
  #
  # It is also possible to use the <tt>Symbol</tt> for the
  # <tt>mecab</tt> node member to index into the 
  # <tt>FFI::Struct</tt> layout associative array like so:
  #     
  #     nm.parse('あいつ笑うと結構可愛い顔してんよ。') {|n| puts n[:feature] }
  #     名詞,代名詞,一般,*,*,*,あいつ,アイツ,アイツ
  #     動詞,自立,*,*,五段・ワ行促音便,基本形,笑う,ワラウ,ワラウ
  #     助詞,接続助詞,*,*,*,*,と,ト,ト
  #     副詞,一般,*,*,*,*,結構,ケッコウ,ケッコー
  #     形容詞,自立,*,*,形容詞・イ段,基本形,可愛い,カワイイ,カワイイ
  #     名詞,一般,*,*,*,*,顔,カオ,カオ
  #     動詞,自立,*,*,サ変・スル,連用形,する,シ,シ
  #     動詞,非自立,*,*,一段,体言接続特殊,てる,テン,テン
  #     助詞,終助詞,*,*,*,*,よ,ヨ,ヨ
  #     記号,句点,*,*,*,*,。,。,。
  #     BOS/EOS,*,*,*,*,*,*,*,*
  #
  class MeCabNode < MeCabStruct
    include Natto::Utils

    attr_accessor :surface, :feature
    attr_reader   :pointer

    # Normal <tt>mecab</tt> node defined in the dictionary.
    NOR_NODE = 0
    # Unknown <tt>mecab</tt> node not defined in the dictionary.
    UNK_NODE = 1
    # Virtual node representing the beginning of the sentence.
    BOS_NODE = 2
    # Virutual node representing the end of the sentence.
    EOS_NODE = 3
    # Virtual node representing the end of an N-Best <tt>mecab</tt> node list.
    EON_NODE = 4

    layout  :prev,            :pointer,
            :next,            :pointer,
            :enext,           :pointer,
            :bnext,           :pointer,
            :rpath,           :pointer,
            :lpath,           :pointer,
            :surface,         :string,
            :feature,         :string,
            :id,              :uint,
            :length,          :ushort,
            :rlength,         :ushort,
            :rcAttr,          :ushort,
            :lcAttr,          :ushort,
            :posid,           :ushort,
            :char_type,       :uchar,
            :stat,            :uchar,
            :isbest,          :uchar,
            :alpha,           :float,
            :beta,            :float,
            :prob,            :float,
            :wcost,           :short,
            :cost,            :long
   
    if RUBY_VERSION.to_f < 1.9
      alias_method :deprecated_id, :id
      # <tt>Object#id</tt> override defined when <tt>RUBY_VERSION</tt> is
      # older than 1.9. This is a hack to avoid the <tt>Object#id</tt>
      # deprecation warning thrown up in Ruby 1.8.7.
      #
      # <i>This method override is not defined when the Ruby interpreter
      # is 1.9 or greater.</i>
      # @return [Fixnum] <tt>mecab</tt> node id
      def id
        self[:id]
      end
    end

    # Initializes this node instance.
    # Sets the <tt>MeCab</tt> feature value for this node.
    #
    # @param [FFI::Pointer]
    def initialize(ptr)
      super(ptr)
      @pointer = ptr

      if self[:feature]
        @feature = self.class.force_enc(self[:feature])
      end
    end
     
    # Returns human-readable details for the <tt>mecab</tt> node.
    # Overrides <tt>Object#to_s</tt>.
    #
    # - encoded object id
    # - underlying FFI pointer to MeCab Node 
    # - stat (node type: NOR, UNK, BOS/EOS, EON)
    # - surface 
    # - feature
    #
    # @return [String] encoded object id, underlying FFI pointer, stat, surface, and feature 
    def to_s
      %(#{super.chop} @pointer=#{@pointer}, stat=#{self[:stat]}, @surface="#{self.surface}", @feature="#{self.feature}">)
    end

    # Overrides <tt>Object#inspect</tt>.
    #
    # @return [String] encoded object id, stat, surface, and feature 
    # @see #to_s
    def inspect
      self.to_s
    end

    # Returns <tt>true</tt> if this is a normal <tt>mecab</tt> node found in the dictionary.
    # @return [Boolean]
    def is_nor?
      self.stat == NOR_NODE
    end

    # Returns <tt>true</tt> if this is an unknown <tt>mecab</tt> node not found in the dictionary.
    # @return [Boolean]
    def is_unk?
      self.stat == UNK_NODE
    end
   
    # Returns <tt>true</tt> if this is a virtual <tt>mecab</tt> node representing the beginning of the sentence.
    # @return [Boolean]
    def is_bos?
      self.stat == BOS_NODE
    end
   
    # Returns <tt>true</tt> if this is a virtual <tt>mecab</tt> node representing the end of the sentence.
    # @return [Boolean]
    def is_eos?
      self.stat == EOS_NODE 
    end
   
    # Returns <tt>true</tt> if this is a virtual <tt>mecab</tt> node representing the end of the node list.
    # @return [Boolean]
    def is_eon?
      self.stat == EON_NODE
    end
  end
end

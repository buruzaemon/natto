# coding: utf-8
require 'natto/binding'
require 'natto/option_parse'

module Natto 
  require 'ffi'

  # `MeCabStruct` is a general base class for `FFI::Struct` objects in
  # the `Natto` module. Please refer to
  # [`mecab.h`](http://code.google.com/p/mecab/source/browse/trunk/mecab/src/mecab.h)
  class MeCabStruct < FFI::Struct
    # Provides accessor methods for the members of the `mecab` struct.
    #
    # @param [String] attr_name
    # @return member values for the `mecab` struct
    # @raise [NoMethodError] if `attr_name` is not a member of this `mecab` struct 
    def method_missing(attr_name)
      member_sym = attr_name.id2name.to_sym
      return self[member_sym] if self.members.include?(member_sym)
      raise(NoMethodError.new("undefined method '#{attr_name}' for #{self}"))
    end
  end

  # `DictionaryInfo` is a wrapper for the `struct mecab_dictionary_info_t`
  # structure holding the `MeCab` instance's related dictionary information.
  # 
  # Values for the `mecab` dictionary attributes may be 
  # obtained by using the following `Symbol`s as keys 
  # to the layout associative array of `FFI::Struct` members.
  #
  # - :filename - filename of dictionary; on Windows, filename is stored in UTF-8 encoding
  # - :charset - character set of the dictionary
  # - :size - number of words contained in dictionary
  # - :type - dictionary type: 0 (system), 1 (user-defined), 2 (unknown)
  # - :lsize - left attributes size
  # - :rsize - right attributes size
  # - :version - version of this dictionary
  # - :next - pointer to next dictionary in list
  # 
  # ## Usage
  # `mecab` dictionary attributes can be obtained by
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
      # `Object#type` override defined when both `type` and
      # `class` are Object methods. This is a hack to avoid the 
      # `Object#type` deprecation warning thrown up in Ruby 1.8.7
      # and in JRuby.
      #
      # @return [Fixnum] `mecab` dictionary type
      def type
        self[:type]
      end
    end

    # Returns human-readable details for this `mecab` dictionary.
    # Overrides `Object#to_s`.
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
    
    # Overrides `Object#inspect`.
    #
    # @return [String] encoded object id, dictionary filename, and charset
    # @see #to_s
    def inspect
      self.to_s
    end

    # Returns `true` if this is a system dictionary.
    # @return [Boolean]
    def is_sysdic?
      self.type == SYS_DIC
    end

    # Returns `true` if this is a user dictionary.
    # @return [Boolean]
    def is_usrdic?
      self.type == USR_DIC
    end

    # Returns `true` if this is a unknown dictionary type.
    # @return [Boolean]
    def is_unkdic?
      self.type == UNK_DIC
    end
  end

  # `MeCabNode` is a wrapper for the `struct mecab_node_t`
  # structure holding the parsed `node`.
  # 
  # Values for the `mecab` node attributes may be 
  # obtained by using the following `Symbol`s as keys 
  # to the layout associative array of `FFI::Struct` members.
  #
  # - :prev - pointer to previous node
  # - :next - pointer to next node
  # - :enext - pointer to the node which ends at the same position
  # - :bnext - pointer to the node which starts at the same position
  # - :rpath - pointer to the right path; nil if MECAB_ONE_BEST mode
  # - :lpath - pointer to the right path; nil if MECAB_ONE_BEST mode
  # - :surface - surface string; length may be obtainedi with length/rlength members
  # - :feature - feature string
  # - :id - unique node id
  # - :length - length of surface form
  # - :rlength - length of the surface form including white space before the morph
  # - :rcAttr - right attribute id
  # - :lcAttr - left attribute id
  # - :posid - part-of-speech id
  # - :char_type - character type
  # - :stat - node status; 0 (NOR), 1 (UNK), 2 (BOS), 3 (EOS), 4 (EON)
  # - :isbest - 1 if this node is best node
  # - :alpha - forward accumulative log summation, only with marginal probability flag
  # - :beta - backward accumulative log summation, only with marginal probability flag
  # - :prob - marginal probability, only with marginal probability flag
  # - :wcost - word cost
  # - :cost - best accumulative cost from bos node to this node
  #
  # ## Usage
  # An instance of `MeCabNode` is yielded to the block
  # used with `MeCab#parse`, where the above-mentioned
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
  # It is also possible to use the `Symbol` for the
  # `mecab` node member to index into the 
  # `FFI::Struct` layout associative array like so:
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
    attr_accessor :surface, :feature
    attr_reader   :pointer

    # Normal `mecab` node defined in the dictionary, c.f. `stat`.
    NOR_NODE = 0
    # Unknown `mecab` node not defined in the dictionary, c.f. `stat`.
    UNK_NODE = 1
    # Virtual node representing the beginning of the sentence, c.f. `stat`.
    BOS_NODE = 2
    # Virutual node representing the end of the sentence, c.f. `stat`.
    EOS_NODE = 3
    # Virtual node representing the end of an N-Best `mecab` node list, c.f. `stat`.
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

    # Initializes this node instance.
    # Sets the `MeCab` feature value for this node.
    #
    # @param [FFI::Pointer]
    def initialize(ptr)
      super(ptr)
      @pointer = ptr

      if self[:feature]
        @feature = self[:feature].force_encoding(Encoding.default_external)
      end
    end
     
    # Returns human-readable details for the `mecab` node.
    # Overrides `Object#to_s`.
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

    # Overrides `Object#inspect`.
    #
    # @return [String] encoded object id, stat, surface, and feature 
    # @see #to_s
    def inspect
      self.to_s
    end

    # Returns `true` if this is a normal `mecab` node found in the dictionary.
    # @return [Boolean]
    def is_nor?
      self.stat == NOR_NODE
    end

    # Returns `true` if this is an unknown `mecab` node not found in the dictionary.
    # @return [Boolean]
    def is_unk?
      self.stat == UNK_NODE
    end
   
    # Returns `true` if this is a virtual `mecab` node representing the beginning of the sentence.
    # @return [Boolean]
    def is_bos?
      self.stat == BOS_NODE
    end
   
    # Returns `true` if this is a virtual `mecab` node representing the end of the sentence.
    # @return [Boolean]
    def is_eos?
      self.stat == EOS_NODE 
    end
   
    # Returns `true` if this is a virtual `mecab` node representing the end of the node list.
    # @return [Boolean]
    def is_eon?
      self.stat == EON_NODE
    end
  end
end

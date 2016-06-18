# coding: utf-8
require 'natto/binding'
require 'natto/option_parse'

module Natto 
  require 'ffi'

  # `MeCabStruct` is a general base class for `FFI::Struct` objects in
  # the `Natto` module. Please refer to `mecab.h` in the source code
  # distribution.
  class MeCabStruct < FFI::Struct
    # Provides accessor methods for the members of the MeCab struct.
    # @param attr_name [String] attribute name
    # @return member values for the MeCab struct
    # @raise [NoMethodError] if `attr_name` is not a member of this MeCab struct 
    def method_missing(attr_name)
      member_sym = attr_name.id2name.to_sym
      self[member_sym]
    rescue ArgumentError # `member_sym` field doesn't exist.
      raise(NoMethodError.new("undefined method '#{attr_name}' for #{self}"))
    end
  end

  # `DictionaryInfo` is a wrapper for the `struct mecab_dictionary_info_t`
  # structure holding the MeCab instance's related dictionary information.
  # 
  # Values for the MeCab dictionary attributes may be 
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
  # MeCab dictionary attributes can be obtained by
  # using their corresponding accessor.
  #
  #     nm = Natto::MeCab.new
  #
  #     sysdic = nm.dicts.first
  #    
  #     # display the real path to the mecab lib
  #     puts sysdic.filepath
  #     => /usr/local/lib/mecab/dic/ipadic/sys.dic
  #
  #     # what charset (encoding) is the system dictionary?
  #     puts sysdic.charset
  #     => utf8
  # 
  #     # is this really the system dictionary?
  #     puts sysdic.is_sysdic?
  #     => true
  class DictionaryInfo < MeCabStruct
    # @return [String] Absolute filepath to MeCab dictionary.
    attr_reader :filepath

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
      # @return [Fixnum] MeCab dictionary type
      def type
        self[:type]
      end
    end

    # Initializes this dictionary info instance.
    # Sets the `DictionaryInfo` filepath value.
    # @param ptr [FFI::Pointer] pointer to MeCab dictionary
    def initialize(ptr)
      super(ptr)

      @filepath = File.absolute_path(self[:filename])
    end

    # Returns human-readable details for this MeCab dictionary.
    # Overrides `Object#to_s`.
    #
    # - encoded object id
    # - real file path to this dictionary
    # - dictionary charset
    # - dictionary type
    # @return [String] encoded object id, file path to dictionary, charset and
    # type
    def to_s
      [ super.chop,
        "@filepath=\"#{@filepath}\",", 
         "charset=#{self.charset},", 
         "type=#{self.type}>" ].join(' ')
    end
    
    # Overrides `Object#inspect`.
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
  # Values for the MeCab node attributes may be 
  # obtained by using the following `Symbol`s as keys 
  # to the layout associative array of `FFI::Struct` members.
  #
  # - :prev - pointer to previous node
  # - :next - pointer to next node
  # - :enext - pointer to the node which ends at the same position
  # - :bnext - pointer to the node which starts at the same position
  # - :rpath - pointer to the right path; nil if MECAB_ONE_BEST mode
  # - :lpath - pointer to the right path; nil if MECAB_ONE_BEST mode
  # - :surface - surface string; length may be obtained with length/rlength members
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
  #     なんて    4398
  #     死ぬ     9261
  #     まで     9386
  #     の       10007
  #     暇つぶし 13324
  #     だ       15346
  #     よ       14396
  #     。       10194
  #
  # While it is also possible to use the `Symbol` for the
  # MeCab node member to index into the 
  # `FFI::Struct` layout associative array, please use the attribute
  # accessors. In the case of `:surface` and `:feature`, MeCab 
  # returns the raw bytes, so `natto` will convert that into
  # a string using the default encoding.
  class MeCabNode < MeCabStruct
    # @return [String] surface morpheme surface value.
    attr_accessor :surface
    # @return [String] corresponding feature value.
    attr_accessor :feature
    # @return [FFI::Pointer] pointer to MeCab node struct.
    attr_reader   :pointer

    # Normal MeCab node defined in the dictionary, c.f. `stat`.
    NOR_NODE = 0
    # Unknown MeCab node not defined in the dictionary, c.f. `stat`.
    UNK_NODE = 1
    # Virtual node representing the beginning of the sentence, c.f. `stat`.
    BOS_NODE = 2
    # Virutual node representing the end of the sentence, c.f. `stat`.
    EOS_NODE = 3
    # Virtual node representing the end of an N-Best MeCab node list, c.f. `stat`.
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
    # Sets the MeCab feature value for this node.
    # @param nptr [FFI::Pointer] pointer to MeCab node
    def initialize(nptr)
      super(nptr)
      @pointer = nptr

      if self[:feature]
        @feature = self[:feature].force_encoding(Encoding.default_external)
      end
    end
     
    # Returns human-readable details for the MeCab node.
    # Overrides `Object#to_s`.
    #
    # - encoded object id
    # - underlying FFI pointer to MeCab Node 
    # - stat (node type: NOR, UNK, BOS/EOS, EON)
    # - surface 
    # - feature
    # @return [String] encoded object id, underlying FFI pointer, stat, surface, and feature 
    def to_s
       [ super.chop,
         "@pointer=#{@pointer},",
         "stat=#{self[:stat]},", 
         "@surface=\"#{self.surface}\",",
         "@feature=\"#{self.feature}\">" ].join(' ')
    end

    # Overrides `Object#inspect`.
    # @return [String] encoded object id, stat, surface, and feature 
    # @see #to_s
    def inspect
      self.to_s
    end

    # Returns `true` if this is a normal MeCab node found in the dictionary.
    # @return [Boolean]
    def is_nor?
      self.stat == NOR_NODE
    end

    # Returns `true` if this is an unknown MeCab node not found in the dictionary.
    # @return [Boolean]
    def is_unk?
      self.stat == UNK_NODE
    end
   
    # Returns `true` if this is a virtual MeCab node representing the beginning of the sentence.
    # @return [Boolean]
    def is_bos?
      self.stat == BOS_NODE
    end
   
    # Returns `true` if this is a virtual MeCab node representing the end of the sentence.
    # @return [Boolean]
    def is_eos?
      self.stat == EOS_NODE 
    end
   
    # Returns `true` if this is a virtual MeCab node representing the end of the node list.
    # @return [Boolean]
    def is_eon?
      self.stat == EON_NODE
    end
  end
end

# Copyright (c) 2016, Brooke M. Fujita.
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 
#  * Redistributions of source code must retain the above
#    copyright notice, this list of conditions and the
#    following disclaimer.
# 
#  * Redistributions in binary form must reproduce the above
#    copyright notice, this list of conditions and the
#    following disclaimer in the documentation and/or other
#    materials provided with the distribution.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
# ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

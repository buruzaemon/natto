# coding: utf-8
require 'rubygems' if RUBY_VERSION.to_f < 1.9
require 'natto/binding'
require 'natto/option_parse'
require 'natto/utils'

module Natto 
  require 'ffi'

  # <tt>MeCab</tt> is a wrapper class for the <tt>mecab</tt> tagger.
  # Options to the <tt>mecab</tt> tagger are passed in as a string
  # (MeCab command-line style) or as a Ruby-style hash at
  # initialization.
  #
  # <h2>Usage</h2>
  #
  #     require 'rubygems' if RUBY_VERSION.to_f < 1.9
  #     require 'natto'
  #
  #     nm = Natto::MeCab.new('-Ochasen')
  #     => #<Natto::MeCab:0x28d3bdc8 \
  #          @tagger=#<FFI::Pointer address=0x28afb980>, \
  #          @options={:output_format_type=>"chasen"},   \
  #          @dicts=[#<Natto::DictionaryInfo:0x289a1f14  \
  #                    type="0", \
  #                    filename="/usr/local/lib/mecab/dic/ipadic/sys.dic", \
  #                    charset="utf8">], \
  #          @version="0.994">
  #
  #     nm.parse('凡人にしか見えねえ風景ってのがあるんだよ。') do |n| 
  #       puts "#{n.surface}\t#{n.feature}" 
  #     end 
  #     凡人   名詞,一般,*,*,*,*,凡人,ボンジン,ボンジン
  #     に     助詞,格助詞,一般,*,*,*,に,ニ,ニ 
  #     しか   助詞,係助詞,*,*,*,*,しか,シカ,シカ 
  #     見え   動詞,自立,*,*,一段,未然形,見える,ミエ,ミエ
  #     ねえ   助動詞,*,*,*,特殊・ナイ,音便基本形,ない,ネエ,ネー 
  #     風景   名詞,一般,*,*,*,*,風景,フウケイ,フーケイ
  #     って   助詞,格助詞,連語,*,*,*,って,ッテ,ッテ
  #     の     名詞,非自立,一般,*,*,*,の,ノ,ノ 
  #     が     助詞,格助詞,一般,*,*,*,が,ガ,ガ
  #     ある   動詞,自立,*,*,五段・ラ行,基本形,ある,アル,アル 
  #     ん     名詞,非自立,一般,*,*,*,ん,ン,ン
  #     だ     助動詞,*,*,*一般,特殊・ダ,基本形,だ,ダ,ダ
  #     よ     助詞,終助詞,*,*,*,*,よ,ã¨,ヨ
  #     。     記号,句点,*,*,*,*,。,。,。
  #            BOS/EOS,*,*,*,*,*,*,*,*BOS
  #
  class MeCab
    include Natto::Binding
    include Natto::OptionParse
    include Natto::Utils

    attr_reader :tagger, :options, :dicts, :version

    # Initializes the wrapped <tt>mecab</tt> instance with the
    # given <tt>options</tt>.
    # 
    # Options supported are:
    #
    # - :rcfile --  resource file
    # - :dicdir --  system dicdir
    # - :userdic --  user dictionary
    # - :lattice_level --  lattice information level (DEPRECATED)
    # - :output_format_type --  output format type (wakati, chasen, yomi, etc.)
    # - :all_morphs --  output all morphs (default false)
    # - :nbest --  output N best results (integer, default 1), requires lattice level >= 1
    # - :node_format --  user-defined node format
    # - :unk_format --  user-defined unknown node format
    # - :bos_format --  user-defined beginning-of-sentence format
    # - :eos_format --  user-defined end-of-sentence format
    # - :eon_format --  user-defined end-of-NBest format
    # - :unk_feature --  feature for unknown word
    # - :input_buffer_size -- set input buffer size (default 8192) 
    # - :allocate_sentence -- allocate new memory for input sentence 
    # - :theta --  temperature parameter theta (float, default 0.75)
    # - :cost_factor --  cost factor (integer, default 700)
    # 
    # <p>MeCab command-line arguments (-F) or long (--node-format) may be used in 
    # addition to Ruby-style <code>Hash</code>es</p>
    # <i>Use single-quotes to preserve format options that contain escape chars.</i><br/>
    # e.g.<br/>
    #
    #     nm = Natto::MeCab.new(:node_format=>'%m¥t%f[7]¥n')
    #     => #<Natto::MeCab:0x28d2ae10 
    #          @tagger=#<FFI::Pointer address=0x28a97980>, \
    #          @options={:node_format=>"%m¥t%f[7]¥n"},     \
    #          @dicts=[#<Natto::DictionaryInfo:0x28d2a85c  \
    #                    type="0", \
    #                    filename="/usr/local/lib/mecab/dic/ipadic/sys.dic" \
    #                    charset="utf8">], \
    #          @version="0.994">
    # 
    #     puts nm.parse('才能とは求める人間に与えられるものではない。')
    #     才能    サイノウ
    #     と      ト
    #     は      ハ
    #     求      モトメル
    #     人間    ニンゲン
    #     に      ニ
    #     与え    アタエ
    #     られる  ラレル
    #     もの    モノ
    #     で      デ
    #     は      ハ
    #     ない    ナイ
    #     。      。
    #     EOS
    #
    # @param [Hash or String]
    # @raise [MeCabError] if <tt>mecab</tt> cannot be initialized with the given <tt>options</tt>
    def initialize(options={})
      @options = self.class.parse_mecab_options(options) 
      @dicts = []

      opt_str = self.class.build_options_str(@options)
      @tagger = self.mecab_new2(opt_str)
      raise MeCabError.new("Could not initialize MeCab with options: '#{opt_str}'") if @tagger.address == 0x0

      self.mecab_set_theta(@tagger, @options[:theta]) if @options[:theta]
      self.mecab_set_lattice_level(@tagger, @options[:lattice_level]) if @options[:lattice_level]
      self.mecab_set_all_morphs(@tagger, 1) if @options[:all_morphs]
       
      # Set mecab parsing implementations for N-best and regular parsing,
      # for both parsing as string and yielding a node object
      # N-Best parsing implementations
      if @options[:nbest] && @options[:nbest] > 1
        self.mecab_set_lattice_level(@tagger, (@options[:lattice_level] || 1))
        @parse_tostr = lambda do |str| 
          return self.mecab_nbest_sparse_tostr(@tagger, @options[:nbest], str) || 
                raise(MeCabError.new(self.mecab_strerror(@tagger))) 
        end 
        @parse_tonodes = lambda do |str| 
          nodes = []
          if @options[:nbest] && @options[:nbest] > 1
            self.mecab_nbest_init(@tagger, str) 
            n = self.mecab_nbest_next_tonode(@tagger)
            raise(MeCabError.new(self.mecab_strerror(@tagger))) if n.nil? || n.address==0x0
            nlen = @options[:nbest]
            nlen.times do |i|
              s = str.bytes.to_a
              while n && n.address != 0x0
                mn = Natto::MeCabNode.new(n)
                s = s.drop_while {|e| (e==0xa || e==0x20)}
                if !s.empty?
                  sarr = []
                  mn.length.times { sarr << s.shift }
                  surf = sarr.pack('C*')
                  mn.surface = self.class.force_enc(surf)
                end
                if @options[:output_format_type] || @options[:node_format]
                  mn.feature = self.class.force_enc(self.mecab_format_node(@tagger, n)) 
                end
                nodes << mn if !mn.is_bos?
                n = mn.next
              end
              n = self.mecab_nbest_next_tonode(@tagger)
            end
          end
          return nodes
        end
      else
        # default parsing implementations
        @parse_tostr = lambda do |str|
          return self.mecab_sparse_tostr(@tagger, str) || 
                raise(MeCabError.new(self.mecab_strerror(@tagger))) 
        end
        @parse_tonodes = lambda do |str| 
          nodes = []
          n = self.mecab_sparse_tonode(@tagger, str) 
          raise(MeCabError.new(self.mecab_strerror(@tagger))) if n.nil? || n.address==0x0
          mn = Natto::MeCabNode.new(n)
          n = mn.next if mn.next.address!=0x0
          s = str.bytes.to_a
          while n && n.address!=0x0
            mn = Natto::MeCabNode.new(n)
            s = s.drop_while {|e| (e==0xa || e==0x20)}
            if !s.empty?
              sarr = []
              mn.length.times { sarr << s.shift }
              surf = sarr.pack('C*')
              mn.surface = self.class.force_enc(surf)
            end
            nodes << mn 
            n = mn.next
          end
          return nodes
        end
      end

      @dicts << Natto::DictionaryInfo.new(Natto::Binding.mecab_dictionary_info(@tagger))
      while @dicts.last.next.address != 0x0
        @dicts << Natto::DictionaryInfo.new(@dicts.last.next)
      end

      @version = self.mecab_version

      ObjectSpace.define_finalizer(self, self.class.create_free_proc(@tagger))
    end
    
    # Parses the given string <tt>str</tt>. If a block is passed to this method,
    # then node parsing will be used and each node yielded to the given block.
    #
    # @param [String] str
    # @return parsing result from <tt>mecab</tt>
    # @raise [MeCabError] if the <tt>mecab</tt> tagger cannot parse the given string <tt>str</tt>
    # @see MeCabNode
    def parse(str)
      if block_given?
        nodes = @parse_tonodes.call(str)
        nodes.each {|n| yield n }
      else
        self.class.force_enc(@parse_tostr.call(str))
      end
    end

    # Parses the given string <tt>str</tt>, and returns
    # a list of <tt>mecab</tt> nodes.
    # @param [String] str
    # @return [Array] of parsed <tt>mecab</tt> nodes.
    # @raise [MeCabError] if the <tt>mecab</tt> tagger cannot parse the given string <tt>str</tt>
    # @see MeCabNode
    def parse_as_nodes(str)
      @parse_tonodes.call(str)
    end

    # Parses the given string <tt>str</tt>, and returns
    # a list of <tt>mecab</tt> result strings.
    # @param [String] str
    # @return [Array] of parsed <tt>mecab</tt> result strings.
    # @raise [MeCabError] if the <tt>mecab</tt> tagger cannot parse the given string <tt>str</tt>
    def parse_as_strings(str)
      self.class.force_enc(@parse_tostr.call(str)).lines.to_a
    end

    # DEPRECATED: use parse_as_nodes instead.
    def readnodes(str)
      $stdout.puts 'DEPRECATED: use parse_as_nodes instead'
      parse_as_nodes(str)
    end

    # DEPRECATED: use parse_as_strings instead.
    def readlines(str)
      $stdout.puts 'DEPRECATED: use parse_as_strings instead'
      parse_as_strings(str)
    end

    # Returns human-readable details for the wrapped <tt>mecab</tt> tagger.
    # Overrides <tt>Object#to_s</tt>.
    #
    # - encoded object id
    # - underlying FFI pointer to the <tt>mecab</tt> tagger
    # - options hash
    # - list of dictionaries
    # - MeCab version
    #
    # @return [String] encoded object id, underlying FFI pointer, options hash, list of dictionaries, and MeCab version
    def to_s
      %(#{super.chop} @tagger=#{@tagger}, @options=#{@options.inspect}, @dicts=#{@dicts.to_s}, @version="#{@version.to_s}">)
    end

    # Overrides <tt>Object#inspect</tt>.
    # 
    # @return [String] encoded object id, FFI pointer, options hash, list of dictionaries, and MeCab version
    # @see #to_s
    def inspect
      self.to_s
    end

    # Returns a <tt>Proc</tt> that will properly free resources
    # when this <tt>MeCab</tt> instance is garbage collected.
    # The <tt>Proc</tt> returned is registered to be invoked
    # after the <tt>MeCab</tt> instance  owning <tt>ptr</tt> 
    # has been destroyed.
    #
    # @param [FFI::Pointer] ptr
    # @return [Proc] to release <tt>mecab</tt> resources properly
    def self.create_free_proc(ptr)
      Proc.new do
        self.mecab_destroy(ptr)
      end
    end
  end

  # <tt>MeCabError</tt> is a general error class 
  # for the <tt>Natto</tt> module.
  class MeCabError < RuntimeError; end

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

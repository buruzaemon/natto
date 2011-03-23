# coding: utf-8

require 'rubygems' if RUBY_VERSION.to_f < 1.9
require 'natto/binding'

module Natto 
  require 'ffi'

  # <tt>MeCab</tt> is a wrapper class for the <tt>mecab</tt> parser.
  # Options to the <tt>mecab</tt> parser are passed in as a hash at
  # initialization.
  #
  # <h2>Usage</h2>
  #
  #     require 'rubygems' if RUBY_VERSION.to_f < 1.9
  #     require 'natto'
  #
  #     nm = Natto::MeCab.new(:output_format_type=>'chasen2')
  #     => #<Natto::MeCab:0x28d3bdc8 \
  #          @ptr=#<FFI::Pointer address=0x28afb980>, \
  #          @options={:output_format_type=>"chasen2"}, \
  #          @dicts=[#<Natto::DictionaryInfo:0x289a1f14 \
  #                    filename="/usr/local/lib/mecab/dic/ipadic/sys.dic", \
  #                    charset="utf8">], \
  #          @version="0.98">
  #
  #     nm.parse('ネバネバの組み合わせ美味しいです。') do |n| 
  #       puts "#{n.surface}\t#{n.feature}" 
  #     end
  #
  #     ネバネバ        名詞,サ変接続,*,*,*,*,ネバネバ,ネバネバ,ネバネバ
  #     の              助詞,連体化,*,*,*,*,の,ノ,ノ
  #     組み合わせ      名詞,一般,*,*,*,*,組み合わせ,クミアワセ,クミアワセ
  #     美味しい        形容詞,自立,*,*,形容詞・イ段,基本形,美味しい,オイシイ,オイシイ
  #     です            助動詞,*,*,*,特殊・デス,基本形,です,デス,デス
  #     。              記号,句点,*,*,*,*,。,。,。
  #
  class MeCab
    include Natto::Binding

    attr_reader :options, :dicts, :version

    # Supported options to the <tt>mecab</tt> parser.
    # See the <tt>mecab</tt> help for more details. 
    SUPPORTED_OPTS = [ :rcfile, :dicdir, :userdic, :lattice_level, :all_morphs,
                       :output_format_type, :node_format, :unk_format, 
                       :bos_format, :eos_format, :eon_format, :unk_feature, 
                       :input_buffer_size, :allocate_sentence, :nbest, :theta, 
                       :cost_factor, :output ].freeze

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
    # - :node_format --  user-defined node format
    # - :unk_format --  user-defined unknown node format
    # - :bos_format --  user-defined beginning-of-sentence format
    # - :eos_format --  user-defined end-of-sentence format
    # - :eon_format --  user-defined end-of-NBest format
    # - :unk_feature --  feature for unknown word
    # - :input_buffer_size -- set input buffer size (default 8192) 
    # - :allocate_sentence -- allocate new memory for input sentence 
    # - :nbest --  output N best results (integer, default 1), requires lattice level >= 1
    # - :theta --  temperature parameter theta (float, default 0.75)
    # - :cost_factor --  cost factor (integer, default 700)
    # - :output -- set the output file name
    # 
    # <i>Use single-quotes to preserve format options that contain escape chars.</i><br/>
    # e.g.<br/>
    #
    #     nm = Natto::MeCab.new(:node_format=>'%m¥t%f[7]¥n')
    #     => #<Natto::MeCab:0x28d2ae10 @ptr=#<FFI::Pointer address=0x28a97980>, \
    #          @options={:node_format=>"%m¥t%f[7]¥n"}, \
    #          @dicts=[#<Natto::DictionaryInfo:0x28d2a85c \
    #                    filename="/usr/local/lib/mecab/dic/ipadic/sys.dic" \
    #                    charset="utf8">], \
    #          @version="0.98">
    #
    #     puts nm.parse('簡単で美味しくて良いですよね。')
    #     簡単       カンタン
    #     で         デ
    #     美味しくて オイシクテ
    #     良い       ヨイ
    #     です       デス
    #     よ         ヨ
    #     ね         ネ
    #     。
    #     EOS
    #     => nil
    #
    # @param [Hash]
    # @raise [MeCabError] if <tt>mecab</tt> cannot be initialized with the given <tt>options</tt>
    # @see MeCab::SUPPORTED_OPTS
    def initialize(options={})
      @options = {}.merge(options)
      @dicts = []

      opt_str = self.class.build_options_str(@options)
      @ptr = self.mecab_new2(opt_str)
      raise MeCabError.new("Could not initialize MeCab with options: '#{opt_str}'") if @ptr.address == 0x0

      # set mecab parsing options
      self.mecab_set_theta(@ptr, @options[:theta].to_f) if @options[:theta]
      self.mecab_set_lattice_level(@ptr, @options[:lattice_level].to_i) if @options[:lattice_level]
      self.mecab_set_all_morphs(@ptr, 1) if @options[:all_morphs]
       
      # Set mecab parsing implementations for N-best and regular parsing,
      # for both parsing as string and yielding a node object
      # N-Best parsing implementations
      if @options[:nbest] && @options[:nbest] > 1
        # nbest parsing require lattice level >= 1
        self.mecab_set_lattice_level(@ptr, (@options[:lattice_level] || 1))
        @parse_tostr = lambda { |str| 
          self.mecab_nbest_init(@ptr, str) 
          return self.mecab_nbest_sparse_tostr(@ptr, @options[:nbest], str) || 
                raise(MeCabError.new(self.mecab_strerror(@ptr))) 
        } 
        @parse_tonode = lambda { |str| 
          self.mecab_nbest_init(@ptr, str) 
          return self.mecab_nbest_next_tonode(@ptr) 
        }
      else
        # default parsing implementations
        @parse_tostr = lambda { |str|
          return self.mecab_sparse_tostr(@ptr, str) || raise(MeCabError.new(self.mecab_strerror(@ptr))) 
        }
        @parse_tonode = lambda { |str| return self.mecab_sparse_tonode(@ptr, str) }
      end

      # set ref to dictionaries
      @dicts << Natto::DictionaryInfo.new(Natto::Binding.mecab_dictionary_info(@ptr))
      while @dicts.last.next.address != 0x0
        @dicts << Natto::DictionaryInfo.new(@dicts.last.next)
      end

      # set ref to mecab version string
      @version = self.mecab_version

      # set Proc for freeing mecab pointer
      ObjectSpace.define_finalizer(self, self.class.create_free_proc(@ptr))
    end
    
    # Parses the given string <tt>str</tt>. If a block is passed to this method,
    # then node parsing will be used and each node yielded to the given block.
    #
    # @param [String] str
    # @return parsing result from <tt>mecab</tt>
    # @raise [MeCabError] if the <tt>mecab</tt> parser cannot parse the given string <tt>str</tt>
    # @see MeCabNode
    def parse(str)
      if block_given?
        m_node_ptr = @parse_tonode.call(str)
        head = Natto::MeCabNode.new(m_node_ptr) 
        if head && head[:next].address != 0x0
          node = Natto::MeCabNode.new(head[:next])
          i = 0
          while node.nil? == false
            if node.length > 0
               node.surface = str.bytes.to_a()[i, node.length].pack('C*')
            end
            yield node
            if node[:next].address != 0x0
              i += node.length
              node = Natto::MeCabNode.new(node[:next])
            else
              break
            end
          end
        end
      else
        result = @parse_tostr.call(str)
        result.force_encoding(Encoding.default_external) if result.respond_to?(:encoding) && result.encoding!=Encoding.default_external
        result
      end
    end

    # Returns human-readable details for the wrapped <tt>mecab</tt> parser.
    # Overrides <tt>Object#to_s</tt>.
    #
    # - encoded object id
    # - FFI pointer to <tt>mecab</tt> object
    # - options hash
    # - list of dictionaries
    # - MeCab version
    #
    # @return [String] encoded object id, FFI pointer, options hash, list of dictionaries, and MeCab version
    def to_s
      %(#{super.chop} @ptr=#{@ptr.to_s}, @options=#{@options.to_s}, @dicts=#{@dicts.to_s}, @version="#{@version.to_s}">)
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

    # Returns a string-representation of the options to
    # be passed in the construction of <tt>mecab</tt>.
    #
    # @param [Hash] options 
    # @return [String] representation of the options to the <tt>mecab</tt> parser
    def self.build_options_str(options={})
      opt = []
      SUPPORTED_OPTS.each do |k|
        if options.has_key? k
          key = k.to_s.gsub('_', '-')  
          # all-morphs and allocate-sentence are just flags
          if %w( all-morphs allocate-sentence ).include? key
            opt << "--#{key}" if options[k]==true
          else
            opt << "--#{key}=#{options[k]}"
          end
        end
      end
      opt.empty? ? "" : opt.join(" ") 
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
  class DictionaryInfo < MeCabStruct

    layout  :filename, :string,
            :charset,  :string,
            :size,     :uint,
            :type,     :int,
            :lsize,    :uint,
            :rsize,    :uint,
            :version,  :ushort,
            :next,     :pointer
   
    if RUBY_VERSION.to_f < 1.9
      alias_method :deprecated_type, :type
      # <tt>Object#type</tt> override defined when <tt>RUBY_VERSION</tt> is
      # older than 1.9. This is a hack to avoid the <tt>Object#type</tt>
      # deprecation warning thrown up in Ruby 1.8.7.
      #
      # <i>This method override is not defined when the Ruby interpreter
      # is 1.9 or greater.</i>
      # @return [Fixnum] <tt>mecab</tt> dictionary type
      def type
        self[:type]
      end
    end

    # Returns human-readable details for this <tt>mecab</tt> dictionary.
    # Overrides <tt>Object#to_s</tt>.
    #
    # - encoded object id
    # - full-path dictionary filename
    # - dictionary charset
    #
    # @return [String] encoded object id, dictionary filename, and charset
    def to_s
      %(#{super.chop} filename="#{self.filename}", charset="#{self.charset}">)
    end
    
    # Overrides <tt>Object#inspect</tt>.
    #
    # @return [String] encoded object id, dictionary filename, and charset
    # @see #to_s
    def inspect
      self.to_s
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
  # - :begin_node_list
  # - :end_node_list
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
  # - :sentence_length
  # - :alpha
  # - :beta
  # - :beta
  # - :prob
  # - :wcost
  # - :cost
  # - :token
  #
  # <h2>Usage</h2>
  # An instance of <tt>MeCabNode</tt> is yielded to a block
  # used with <tt>MeCab#parse</tt>. Each resulting node is
  # yielded to the block passed in, where the above-mentioned
  # node attributes may be accessed.
  #
  #     nm = Natto::MeCab.new
  #
  #     nm.parse('めかぶの使い方がわからなくて困ってました。') do |n| 
  #       puts "#{n.surface}¥t#{n.cost}" 
  #     end
  #
  #     め      7961
  #     かぶ    19303
  #     の      25995
  #     使い方  29182
  #     が      28327
  #     わから  33625
  #     なく    34256
  #     て      36454
  #     困っ    43797
  #     て      42178
  #     まし    46708
  #     た      46111
  #     。      42677
  #             41141
  #     => nil
  #
  # It is also possible to use the <tt>Symbol</tt> for the
  # <tt>mecab</tt> node member to index into the 
  # <tt>FFI::Struct</tt> layout associative array like so:
  #     
  #     nm.parse('納豆に乗っけて頂きます！') {|n| puts n[:feature] }
  #
  #     名詞,一般,*,*,*,*,納豆,ナットウ,ナットー
  #     助詞,格助詞,一般,*,*,*,に,ニ,ニ
  #     動詞,自立,*,*,一段,連用形,乗っける,ノッケ,ノッケ
  #     助詞,接続助詞,*,*,*,*,て,テ,テ
  #     動詞,非自立,*,*,五段・カ行イ音便,連用形,頂く,イタダキ,イタダキ
  #     助動詞,*,*,*,特殊・マス,基本形,ます,マス,マス
  #     記号,一般,*,*,*,*,！,！,！
  #     BOS/EOS,*,*,*,*,*,*,*,*
  #     => nil
  #
  class MeCabNode < MeCabStruct
    attr_accessor :surface, :feature

    # Normal <tt>mecab</tt> node.
    NOR_NODE = 0
    # Unknown <tt>mecab</tt> node.
    UNK_NODE = 1
    # Beginning-of-string <tt>mecab</tt> node.
    BOS_NODE = 2
    # End-of-string <tt>mecab</tt> node.
    EOS_NODE = 3
    # End-of-NBest <tt>mecab</tt> node list.
    EON_NODE = 4

    layout  :prev,            :pointer,
            :next,            :pointer,
            :enext,           :pointer,
            :bnext,           :pointer,
            :rpath,           :pointer,
            :lpath,           :pointer,
            :begin_node_list, :pointer,
            :end_node_list,   :pointer,
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
            :sentence_length, :uint,
            :alpha,           :float,
            :beta,            :float,
            :prob,            :float,
            :wcost,           :short,
            :cost,            :long,
            :token,           :pointer
   
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
    # Sets the <ttMeCab</tt> feature value for this node.
    #
    # @param [FFI::Pointer]
    def initialize(ptr)
      super(ptr)

      if self[:feature]
        @feature = self[:feature]
        @feature.force_encoding(Encoding.default_external) if @feature.respond_to?(:encoding) && @feature.encoding!=Encoding.default_external
      end
    end
     
    # Sets the morpheme surface value for this node.
    #
    # @param [String] 
    def surface=(str)
      if str && self[:length] > 0
        @surface = str
        @surface.force_encoding(Encoding.default_external) if @surface.respond_to?(:encoding) && @surface.encoding!=Encoding.default_external
      end
    end

    # Returns human-readable details for the <tt>mecab</tt> node.
    # Overrides <tt>Object#to_s</tt>.
    #
    # - encoded object id
    # - stat 
    # - surface 
    # - feature
    #
    # @return [String] encoded object id, stat, surface, and feature 
    def to_s
      %(#{super.chop} stat=#{self[:stat]}, surface="#{self.surface}", feature="#{self.feature}">)
    end

    # Overrides <tt>Object#inspect</tt>.
    #
    # @return [String] encoded object id, stat, surface, and feature 
    # @see #to_s
    def inspect
      self.to_s
    end
  end
end

# coding: utf-8
require 'rubygems' if RUBY_VERSION.to_f < 1.9
require 'natto/binding'
require 'natto/utils'

module Natto 
  require 'ffi'
  require 'optparse'

  # <tt>MeCab</tt> is a wrapper class for the <tt>mecab</tt> parser.
  # Options to the <tt>mecab</tt> parser are passed in as a string
  # (MeCab command-line style) or as a Ruby-style hash at
  # initialization.
  #
  # <h2>Usage</h2>
  #
  #     require 'rubygems' if RUBY_VERSION.to_f < 1.9
  #     require 'natto'
  #
  #     nm = Natto::MeCab.new('-Ochasen2')
  #     => #<Natto::MeCab:0x28d3bdc8 \
  #          @tagger=#<FFI::Pointer address=0x28afb980>, \
  #          @options={:output_format_type=>"chasen2"},  \
  #          @dicts=[#<Natto::DictionaryInfo:0x289a1f14  \
  #                    type="0", \
  #                    filename="/usr/local/lib/mecab/dic/ipadic/sys.dic", \
  #                    charset="utf8">], \
  #          @version="0.993">
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
    include Natto::Utils

    attr_reader :tagger, :options, :dicts, :version

    # Mapping of mecab short-style configuration options to the <tt>mecab</tt> parser.
    # See the <tt>mecab</tt> help for more details. 
    SUPPORTED_OPTS = { '-r' => :rcfile, 
                       '-d' => :dicdir, 
                       '-u' => :userdic, 
                       '-l' => :lattice_level, 
                       '-O' => :output_format_type, 
                       '-a' => :all_morphs,
                       '-N' => :nbest, 
                       '-F' => :node_format, 
                       '-U' => :unk_format,
                       '-B' => :bos_format, 
                       '-E' => :eos_format, 
                       '-S' => :eon_format, 
                       '-x' => :unk_feature, 
                       '-b' => :input_buffer_size, 
                       '-C' => :allocate_sentence, 
                       '-t' => :theta, 
                       '-c' => :cost_factor }.freeze

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
    #          @version="0.993">
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
    # @param [Hash or String]
    # @raise [MeCabError] if <tt>mecab</tt> cannot be initialized with the given <tt>options</tt>
    # @see MeCab::SUPPORTED_OPTS
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
        # nbest parsing require lattice level >= 1
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
            nlen.times do
              s = str.bytes.to_a
              while n && n.address != 0x0
                mn = Natto::MeCabNode.new(n)
                if mn.is_nor?
                  slen, sarr = mn.length, []
                  slen.times { sarr << s.shift }
                  surf = sarr.pack('C*')
                  mn.surface = self.class.force_enc(surf)
                  if @options[:output_format_type] || @options[:node_format]
                    mn.feature = self.class.force_enc(self.mecab_format_node(@tagger, n)) 
                  end
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
          n = mn.next if mn.next.address!=0x0 && mn.is_bos?
          s = str.bytes.to_a
          while n && n.address!=0x0
            mn = Natto::MeCabNode.new(n)
            if mn.is_nor?
              slen, sarr = mn.length, []
              slen.times { sarr << s.shift }
              surf = sarr.pack('C*')
              mn.surface = self.class.force_enc(surf)
            end
            nodes << mn 
            n = mn.next
          end
          return nodes
        end
      end

      # set ref to dictionaries
      @dicts << Natto::DictionaryInfo.new(Natto::Binding.mecab_dictionary_info(@tagger))
      while @dicts.last.next.address != 0x0
        @dicts << Natto::DictionaryInfo.new(@dicts.last.next)
      end

      # set ref to mecab version string
      @version = self.mecab_version

      # set Proc for freeing mecab pointer
      ObjectSpace.define_finalizer(self, self.class.create_free_proc(@tagger))
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
    # @raise [MeCabError] if the <tt>mecab</tt> parser cannot parse the given string <tt>str</tt>
    # @see MeCabNode
    def readnodes(str)
      @parse_tonodes.call(str)
    end

    # Parses the given string <tt>str</tt>, and returns
    # a list of <tt>mecab</tt> result strings.
    # @param [String] str
    # @return [Array] of parsed <tt>mecab</tt> result strings.
    # @raise [MeCabError] if the <tt>mecab</tt> parser cannot parse the given string <tt>str</tt>
    def readlines(str)
      self.class.force_enc(@parse_tostr.call(str)).lines.to_a
    end

    # Returns human-readable details for the wrapped <tt>mecab</tt> parser.
    # Overrides <tt>Object#to_s</tt>.
    #
    # - encoded object id
    # - underlying FFI pointer to the MeCab Tagger
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

    # Prepares and returns a hash mapping symbols for
    # the specified, recognized MeCab options, and their
    # values. Will parse and convert string (short or
    # long argument styles) or hash. 
    def self.parse_mecab_options(options={})
      h = {}
      if options.is_a? String
        opts = OptionParser.new do |opts|
          opts.on('-r', '--rcfile ARG')  { |arg| h[:rcfile]   = arg.strip }
          opts.on('-d', '--dicdir ARG')  { |arg| h[:dicdir]   = arg.strip }
          opts.on('-u', '--userdic ARG') { |arg| h[:userdic]  = arg.strip }
          opts.on('-l', '--lattice-level ARG') { |arg| h[:lattice_level]  = arg.strip.to_i } # !deprecated in 0.99!!!
          opts.on('-O', '--output-format-type ARG') { |arg| h[:output_format_type]  = arg.strip }
          opts.on('-a', '--all-morphs')  { |arg| h[:all_morphs]  = true }
          opts.on('-N', '--nbest ARG')   { |arg| h[:nbest]    = arg.strip.to_i }
          #opts.on('-m', '--marginal')  { |arg| h[:marginal]  = true }
          opts.on('-F', '--node-format ARG') { |arg| h[:node_format]  = arg.strip }
          opts.on('-U', '--unk-format ARG') { |arg| h[:unk_format]  = arg.strip }
          opts.on('-B', '--bos-format ARG') { |arg| h[:bos_format]  = arg.strip }
          opts.on('-E', '--eos-format ARG') { |arg| h[:eos_format]  = arg.strip }
          opts.on('-S', '--eon-format ARG') { |arg| h[:eon_format]  = arg.strip }
          opts.on('-x', '--unk-feature ARG') { |arg| h[:unk_feature]  = arg.strip }
          opts.on('-b', '--input-buffer-size ARG')   { |arg| h[:input_buffer_size]  = arg.strip.to_i }
          #opts.on('-M', '--open-mutable-dictionary')  { |arg| h[:open_mutable_dictionary]  = true }
          opts.on('-C', '--allocate-sentence')  { |arg| h[:allocate_sentence]  = true }
          opts.on('-t', '--theta ARG')   { |arg| h[:theta] = arg.strip.to_f }
          opts.on('-c', '--cost-factor ARG')   { |arg| h[:cost_factor] = arg.strip.to_i }
        end
        opts.parse!(options.split)
      else
        SUPPORTED_OPTS.values.each do |k|
          if options.has_key?(k)
            if [ :all_morphs, :allocate_sentence ].include?(k) 
              h[k] = true
            else
              v = options[k]  
              if [ :lattice_level, :input_buffer_size, :nbest, :cost_factor ].include?(k)
                h[k] = v.to_i 
              elsif k == :theta
                h[k] = v.to_f
              else 
                h[k] = v
              end
            end
          end
        end
      end
      raise MeCabError.new("Invalid N value") if h[:nbest] && (h[:nbest] < 1 || h[:nbest] > 512)
      h
    end

    # Returns a string-representation of the options to
    # be passed in the construction of <tt>mecab</tt>.
    #
    # @param [Hash] options 
    # @return [String] representation of the options to the <tt>mecab</tt> parser
    def self.build_options_str(options={})
      opt = []
      SUPPORTED_OPTS.values.each do |k|
        if options.has_key? k
          key = k.to_s.gsub('_', '-')  
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
  #     nm.parse('めかぶの使い方がわからなくて困ってました。') do |n| 
  #       puts "#{n.surface}¥t#{n.cost}" if n.is_nor?
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
     
    # Sets the morpheme surface value for this node.
    #
    # @param [String] 
    #def surface=(str)
    #  if str && self[:length] > 0
    #    @surface = self.class.force_enc(str)
    #  end
    #end

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

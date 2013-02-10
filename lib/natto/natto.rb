# coding: utf-8
require 'natto/binding'
require 'natto/option_parse'
require 'natto/struct'
require 'natto/utils'

module Natto 
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
  #          @version="0.995">
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
    # - :partial --  partial parsing mode 
    # - :marginal --  output marginal probability
    # - :max_grouping_size --  maximum grouping size for unknown words (default 24)
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
    #          @version="0.995">
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
    # @raise [ArgumentError] if the given string <tt>str</tt> argument is <tt>nil</tt>
    # @see MeCabNode
    def parse(str)
      raise ArgumentError.new 'String to parse cannot be nil' if str.nil?
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
    # @raise [ArgumentError] if the given string <tt>str</tt> argument is <tt>nil</tt>
    # @see MeCabNode
    def parse_as_nodes(str)
      raise ArgumentError.new 'String to parse cannot be nil' if str.nil?
      @parse_tonodes.call(str)
    end

    # Parses the given string <tt>str</tt>, and returns
    # a list of <tt>mecab</tt> result strings.
    # @param [String] str
    # @return [Array] of parsed <tt>mecab</tt> result strings.
    # @raise [MeCabError] if the <tt>mecab</tt> tagger cannot parse the given string <tt>str</tt>
    # @raise [ArgumentError] if the given string <tt>str</tt> argument is <tt>nil</tt>
    def parse_as_strings(str)
      raise ArgumentError.new 'String to parse cannot be nil' if str.nil?
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
end

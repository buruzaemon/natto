# coding: utf-8
require 'natto/binding'
require 'natto/option_parse'
require 'natto/struct'

module Natto 
  # `MeCab` is a class providing an interface to the MeCab library.
  # Options to the MeCab Model, Tagger and Lattice are passed in
  # as a string (MeCab command-line style) or as a Ruby-style hash at
  # initialization.
  #
  # ## Usage
  #
  #     require 'natto'
  #
  #     text = '凡人にしか見えねえ風景ってのがあるんだよ。'
  #
  #     nm = Natto::MeCab.new
  #     => #<Natto::MeCab:0x0000080318d278                                  \
  #          @model=#<FFI::Pointer address=0x000008039174c0>,               \
  #          @tagger=#<FFI::Pointer address=0x0000080329ba60>,              \
  #          @lattice=#<FFI::Pointer address=0x000008045bd140>,             \
  #          @libpath="/usr/local/lib/libmecab.so"                          \
  #          @options={},                                                   \
  #          @dicts=[#<Natto::DictionaryInfo:0x0000080318ce90               \
  #                    @filepath="/usr/local/lib/mecab/dic/ipadic/sys.dic", \
  #                    charset=utf8,                                        \
  #                    type=0>],                                            \
  #          @version=0.996>
  #
  #     # print entire MeCab result to stdout
  #     #
  #     puts nm.parse(text)
  #     凡人    名詞,一般,*,*,*,*,凡人,ボンジン,ボンジン
  #     に      助詞,格助詞,一般,*,*,*,に,ニ,ニ
  #     しか    助詞,係助詞,*,*,*,*,しか,シカ,シカ
  #     見え    動詞,自立,*,*,一段,未然形,見える,ミエ,ミエ
  #     ねえ    助動詞,*,*,*,特殊・ナイ,音便基本形,ない,ネエ,ネー
  #     風景    名詞,一般,*,*,*,*,風景,フウケイ,フーケイ
  #     って    助詞,格助詞,連語,*,*,*,って,ッテ,ッテ
  #     の      名詞,非自立,一般,*,*,*,の,ノ,ノ
  #     が      助詞,格助詞,一般,*,*,*,が,ガ,ガ
  #     ある    動詞,自立,*,*,五段・ラ行,基本形,ある,アル,アル
  #     ん      名詞,非自立,一般,*,*,*,ん,ン,ン
  #     だ      助動詞,*,*,*,特殊・ダ,基本形,だ,ダ,ダ
  #     よ      助詞,終助詞,*,*,*,*,よ,ヨ,ヨ
  #     。      記号,句点,*,*,*,*,。,。,。
  #     EOS
  #
  #
  #     # pass a block to iterate over each MeCabNode instance
  #     #
  #     nm.parse(text) do |n| 
  #       puts "#{n.surface},#{n.feature}" if !n.is_eos?
  #     end 
  #     凡人,名詞,一般,*,*,*,*,凡人,ボンジン,ボンジン 
  #     に,助詞,格助詞,一般,*,*,*,に,ニ,ニ 
  #     しか,助詞,係助詞,*,*,*,*,しか,シカ,シカ 
  #     見え,動詞,自立,*,*,一段,未然形,見える,ミエ,ミエ 
  #     ねえ,助動詞,*,*,*,特殊・ナイ,音便基本形,ない,ネエ,ネー 
  #     風景,名詞,一般,*,*,*,*,風景,フウケイ,フーケイ 
  #     って,助詞,格助詞,連語,*,*,*,って,ッテ,ッテ 
  #     の,名詞,非自立,一般,*,*,*,の,ノ,ノ 
  #     が,助詞,格助詞,一般,*,*,*,が,ガ,ガ 
  #     ある,動詞,自立,*,*,五段・ラ行,基本形,ある,アル,アル 
  #     ん,名詞,非自立,一般,*,*,*,ん,ン,ン 
  #     だ,助動詞,*,*,*,特殊・ダ,基本形,だ,ダ,ダ 
  #     よ,助詞,終助詞,*,*,*,*,よ,ヨ,ヨ 
  #     。,記号,句点,*,*,*,*,。,。,。 
  #
  #
  #     # customize MeCabNode feature attribute with node-formatting
  #     # %m   ... morpheme surface
  #     # %F,  ... comma-delimited ChaSen feature values
  #     #          reading (index 7) 
  #     #          part-of-speech (index 0) 
  #     # %h   ... part-of-speech ID (IPADIC)
  #     #
  #     nm = Natto::MeCab.new('-F%m,%F,[7,0],%h')
  #     
  #     # Enumerator effectively iterates the MeCabNodes
  #     #
  #     enum = nm.enum_parse(text)
  #     => #<Enumerator: #<Enumerator::Generator:0x29cc5f8>:each>
  #
  #     # output the feature attribute of each MeCabNode
  #     # only output normal nodes, ignoring any end-of-sentence 
  #     # or unknown nodes 
  #     #
  #     enum.map.with_index {|n,i| puts "#{i}: #{n.feature}" if n.is_nor?} 
  #     0: 凡人,ボンジン,名詞,38
  #     1: に,ニ,助詞,13
  #     2: しか,シカ,助詞,16
  #     3: 見え,ミエ,動詞,31
  #     4: ねえ,ネー,助動詞,25
  #     5: 風景,フーケイ,名詞,38
  #     6: って,ッテ,助詞,15
  #     7: の,ノ,名詞,63
  #     8: が,ガ,助詞,13
  #     9: ある,アル,動詞,31
  #     10: ん,ン,名詞,63
  #     11: だ,ダ,助動詞,25
  #     12: よ,ヨ,助詞,17
  #     13: 。,。,記号,7
  #
  #
  #     # Boundary constraint parsing with output formatting.
  #     # %m   ... morpheme surface
  #     # %f   ... tab-delimited ChaSen feature values
  #     #          part-of-speech (index 0) 
  #     # %2   ... MeCab node status value (1 unknown)
  #     #
  #     nm = Natto::MeCab.new('-F%m,\s%f[0],\s%s')
  #
  #     enum = nm.enum_parse(text, boundary_constraint: /見えねえ風景/)
  #     => #<Enumerator: #<Enumerator::Generator:0x00000801d7aa38>:each>
  #
  #     # output the feature attribute of each MeCabNode
  #     # ignoring any beginning- or end-of-sentence nodes
  #     #
  #     enum.each do |n|
  #       puts n.feature if !(n.is_bos? or n.is_eos?)
  #     end
  #     凡人, 名詞, 0
  #     に, 助詞, 0
  #     しか, 助詞, 0
  #     見えねえ風景, 名詞, 1
  #     って, 助詞, 0
  #     の, 名詞, 0
  #     が, 助詞, 0
  #     ある, 動詞, 0
  #     ん, 名詞, 0
  #     だ, 助動詞, 0
  #     よ, 助詞, 0
  #     。, 記号, 0
  #
  class MeCab
    include Natto::Binding
    include Natto::OptionParse
 
    MECAB_LATTICE_ONE_BEST = 1
    MECAB_LATTICE_NBEST = 2
    MECAB_LATTICE_PARTIAL = 4
    MECAB_LATTICE_MARGINAL_PROB = 8
    MECAB_LATTICE_ALTERNATIVE = 16
    MECAB_LATTICE_ALL_MORPHS = 32
    MECAB_LATTICE_ALLOCATE_SENTENCE = 64

    MECAB_ANY_BOUNDARY = 0
    MECAB_TOKEN_BOUNDARY = 1
    MECAB_INSIDE_TOKEN = 2

    # @return [FFI:Pointer] pointer to MeCab Model.
    attr_reader :model
    # @return [FFI:Pointer] pointer to MeCab Tagger.
    attr_reader :tagger
    # @return [FFI:Pointer] pointer to MeCab Lattice.
    attr_reader :lattice
    # @return [String] absolute filepath to MeCab library.
    attr_reader :libpath
    # @return [Hash] MeCab options as key-value pairs.
    attr_reader :options
    # @return [Array] listing of all of dictionaries referenced.
    attr_reader :dicts
    # @return [String] MeCab version.
    attr_reader :version

    # Initializes the wrapped Tagger instance with the given `options`.
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
    # addition to Ruby-style hashs</p>
    # <i>Use single-quotes to preserve format options that contain escape chars.</i><br/>
    # e.g.<br/>
    #
    #     nm = Natto::MeCab.new(node_format: '%m¥t%f[7]¥n')
    #     => #<Natto::MeCab:0x00000803503ee8                                 \
    #          @model=#<FFI::Pointer address=0x00000802b6d9c0>,              \
    #          @tagger=#<FFI::Pointer address=0x00000802ad3ec0>,             \
    #          @lattice=#<FFI::Pointer address=0x000008035f3980>,            \
    #          @libpath="/usr/local/lib/libmecab.so",                        \
    #          @options={:node_format=>"%m¥t%f[7]¥n"},                       \
    #          @dicts=[#<Natto::DictionaryInfo:0x000008035038f8              \
    #                    @filepath="/usr/local/lib/mecab/dic/ipadic/sys.dic" \
    #                    charset=utf8,                                       \
    #                    type=0>]                                            \
    #          @version=0.996>
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
    # @param options [Hash, String] the MeCab options
    # @raise [MeCabError] if MeCab cannot be initialized with the given `options`
    def initialize(options={})
      @options = self.class.parse_mecab_options(options) 
      opt_str  = self.class.build_options_str(@options)

      @model   = self.class.mecab_model_new2(opt_str)
      if @model.address == 0x0
        raise MeCabError.new("Could not initialize Model with options: '#{opt_str}'")
      end

      @tagger  = self.class.mecab_model_new_tagger(@model)
      if @tagger.address == 0x0
        raise MeCabError.new("Could not initialize Tagger with options: '#{opt_str}'")
      end

      @lattice = self.class.mecab_model_new_lattice(@model)
      if @lattice.address == 0x0
        raise MeCabError.new("Could not initialize Lattice with options: '#{opt_str}'")
      end

      @libpath = self.class.find_library

      if @options[:nbest] && @options[:nbest] > 1
        self.mecab_lattice_set_request_type(@lattice, MECAB_LATTICE_NBEST)
      else
        self.mecab_lattice_set_request_type(@lattice, MECAB_LATTICE_ONE_BEST)
      end
      if @options[:partial]
        self.mecab_lattice_add_request_type(@lattice, MECAB_LATTICE_PARTIAL)
      end
      if @options[:marginal]
        self.mecab_lattice_add_request_type(@lattice,
                                            MECAB_LATTICE_MARGINAL_PROB)
      end
      if @options[:all_morphs]
        # required when node parsing
        #self.mecab_lattice_add_request_type(@lattice, MECAB_LATTICE_NBEST)
        self.mecab_lattice_add_request_type(@lattice,
                                            MECAB_LATTICE_ALL_MORPHS)
      end
      if @options[:allocate_sentence]
        self.mecab_lattice_add_request_type(@lattice, 
                                            MECAB_LATTICE_ALLOCATE_SENTENCE)
      end

      if @options[:theta]
        self.mecab_lattice_set_theta(@lattice, @options[:theta]) 
      end

      @parse_tostr = ->(text, constraints) {
        begin
          if @options[:nbest] && @options[:nbest] > 1
            n = @options[:nbest]
          else
            n = 1
          end

          if constraints[:boundary_constraints]
            tokens = tokenize_by_pattern(text,
                                         constraints[:boundary_constraints])
            text = tokens.map {|t| t.first}.join
            self.mecab_lattice_set_sentence(@lattice, text)

            bpos = 0
            tokens.each do |token|
              c = token.first.bytes.count

              self.mecab_lattice_set_boundary_constraint(@lattice,
                                                         bpos,
                                                         MECAB_TOKEN_BOUNDARY)
              bpos += 1

              mark = token.last ? MECAB_INSIDE_TOKEN : MECAB_ANY_BOUNDARY
              (c-1).times do
                self.mecab_lattice_set_boundary_constraint(@lattice,
                                                           bpos,
                                                           mark)
                bpos += 1
              end
            end
          elsif constraints[:feature_constraints]
            features = constraints[:feature_constraints]
            tokens = tokenize_by_features(text,
                                          features.keys)
            text = tokens.map {|t| t.first}.join
            self.mecab_lattice_set_sentence(@lattice, text)

            bpos = 0
            tokens.each do |token|
              chunk = token.first
              c = chunk.bytes.count
              if token.last
                self.mecab_lattice_set_feature_constraint(@lattice,
                                                          bpos,
                                                          bpos+c,
                                                          features[chunk])
              end
              bpos += c
            end
          else
            self.mecab_lattice_set_sentence(@lattice, text)
          end

          self.mecab_parse_lattice(@tagger, @lattice)
          
          if n > 1
            retval = self.mecab_lattice_nbest_tostr(@lattice, n)
          else
            retval = self.mecab_lattice_tostr(@lattice)
          end
          retval.force_encoding(Encoding.default_external)
        rescue
          raise(MeCabError.new(self.mecab_lattice_strerror(@lattice))) 
        end
      }
        
      @parse_tonodes = ->(text, constraints) {
        self.mecab_lattice_add_request_type(@lattice, MECAB_LATTICE_NBEST)
        Enumerator.new do |y|
          begin
            if @options[:nbest] && @options[:nbest] > 1
              n = @options[:nbest]
            else
              n = 1
            end

            if constraints[:boundary_constraints]
              tokens = tokenize_by_pattern(text,
                                           constraints[:boundary_constraints])
              text = tokens.map {|t| t.first}.join
              self.mecab_lattice_set_sentence(@lattice, text)

              bpos = 0
              tokens.each do |token|
                c = token.first.bytes.count

                self.mecab_lattice_set_boundary_constraint(@lattice,
                                                           bpos,
                                                           MECAB_TOKEN_BOUNDARY)
                bpos += 1

                mark = token.last ? MECAB_INSIDE_TOKEN : MECAB_ANY_BOUNDARY
                (c-1).times do
                  self.mecab_lattice_set_boundary_constraint(@lattice, bpos, mark)
                  bpos += 1
                end
              end
            elsif constraints[:feature_constraints]
              features = constraints[:feature_constraints]
              tokens = tokenize_by_features(text,
                                            features.keys)
              text = tokens.map {|t| t.first}.join
              self.mecab_lattice_set_sentence(@lattice, text)

              bpos = 0
              tokens.each do |token|
                chunk = token.first
                c = chunk.bytes.count
                if token.last
                  self.mecab_lattice_set_feature_constraint(@lattice,
                                                            bpos,
                                                            bpos+c,
                                                            features[chunk])
                end
                bpos += c
              end
            else
              self.mecab_lattice_set_sentence(@lattice, text)
            end

            self.mecab_parse_lattice(@tagger, @lattice)

            n.times do
              check = self.mecab_lattice_next(@lattice)
              if check
                nptr = self.mecab_lattice_get_bos_node(@lattice)
          
                while nptr && nptr.address!=0x0
                  mn = Natto::MeCabNode.new(nptr)
                  if !mn.is_bos?
                    surf = mn[:surface].bytes.to_a.slice(0,mn.length).pack('C*')
                    mn.surface = surf.force_encoding(Encoding.default_external)
                    if @options[:output_format_type] || @options[:node_format]
                      mn.feature = self.mecab_format_node(@tagger, nptr).force_encoding(Encoding.default_external)
                    end
                    y.yield mn
                  end
                  nptr = mn[:next]
                end
              end
            end
            nil
          rescue
            raise(MeCabError.new(self.mecab_lattice_strerror(@lattice))) 
          end
        end
      }

      @dicts = []
      @dicts << Natto::DictionaryInfo.new(self.mecab_model_dictionary_info(@model))
      while @dicts.last.next.address != 0x0
        @dicts << Natto::DictionaryInfo.new(@dicts.last.next)
      end

      @version = self.mecab_version

      ObjectSpace.define_finalizer(self, self.class.create_free_proc(@model,
                                                                     @tagger,
                                                                     @lattice))
    end
    
    # Parses the given `text`, returning the MeCab output as a single string. 
    # If a block is passed to this method, then node parsing will be used
    # and each node yielded to the given block.
    #
    # Boundary constraint parsing is available via passing in the
    # `boundary_constraints` key in the `options` hash. Boundary constraints
    # parsing provides hints to MeCab on where the morpheme boundaries in the
    # given `text` are located. `boundary_constraints` value may be either a
    # `Regexp` or `String`; please see [String#scan](http://ruby-doc.org/core-2.2.1/String.html#method-i-scan)
    # The boundary constraint parsed output will be returned as a single
    # string, unless a block is passed to this method for node parsing.
    #
    # Feature constraint parsing is available by passing in the 
    # `feature_constraints` key in the `options` hash. Feature constraints
    # parsing provides instructions to MeCab to use the feature indicated
    # for any morpheme that is an exact match for the given key. 
    # `feature_constraints` is a hash mapping a specific morpheme (String)
    # to a corresponding feature value (String).
    # @param text [String] the Japanese text to parse
    # @param constraints [Hash] `boundary_constraints` or `feature_constraints`
    # @return [String] parsing result from MeCab
    # @raise [MeCabError] if the MeCab Tagger cannot parse the given `text`
    # @raise [ArgumentError] if the given string `text` argument is `nil`
    # @see MeCabNode
    def parse(text, constraints={})
      if text.nil?
        raise ArgumentError.new 'Text to parse cannot be nil'
      elsif constraints[:boundary_constraints]
        if !(constraints[:boundary_constraints].is_a?(Regexp) ||
             constraints[:boundary_constraints].is_a?(String))
          raise ArgumentError.new 'boundary constraints must be a Regexp or String'
        end
      elsif constraints[:feature_constraints] && !constraints[:feature_constraints].is_a?(Hash)
        raise ArgumentError.new 'feature constraints must be a Hash'
      elsif @options[:partial] && !text.end_with?("\n")
        raise ArgumentError.new 'partial parsing requires new-line char at end of text'
      end

      if block_given?
        @parse_tonodes.call(text, constraints).each {|n| yield n }
      else
        @parse_tostr.call(text, constraints)
      end
    end

    # Parses the given string `text`, returning an
    # [Enumerator](http://www.ruby-doc.org/core-2.2.1/Enumerator.html) that may be
    # used to iterate over the resulting {MeCabNode} objects. This is more 
    # efficient than parsing to a simple string, since each node's
    # information will not be materialized all at once as it is with
    # string output.
    #
    # MeCab nodes contain much more detailed information about
    # the morpheme. Node-formatting  may also be used to customize
    # the resulting node's `feature` attribute.
    #
    # Boundary constraint parsing is available by passing in the
    # `boundary_constraints` key in the `options` hash. Boundary constraints
    # parsing provides hints to MeCab on where the morpheme boundaries in the
    # given `text` are located. `boundary_constraints` value may be either a
    # `Regexp` or `String`; please see 
    # [String#scan](http://ruby-doc.org/core-2.2.1/String.html#method-i-scan)
    #
    # Feature constraint parsing is available by passing in the 
    # `feature_constraints` key in the `options` hash. Feature constraints
    # parsing provides instructions to MeCab to use the feature indicated
    # for any morpheme that is an exact match for the given key. 
    # `feature_constraints` is a hash mapping a specific morpheme (String)
    # to a corresponding feature value (String).
    # @param text [String] the Japanese text to parse
    # @param constraints [Hash] `boundary_constraints` or `feature_constraints`
    # @return [Enumerator] of MeCabNode instances
    # @raise [MeCabError] if the MeCab Tagger cannot parse the given `text`
    # @raise [ArgumentError] if the given string `text` argument is `nil`
    # @see MeCabNode
    # @see http://ruby-doc.org/core-2.2.1/Enumerator.html
    def enum_parse(text, constraints={})
      if text.nil?
        raise ArgumentError.new 'Text to parse cannot be nil'
      elsif constraints[:boundary_constraints]
        if !(constraints[:boundary_constraints].is_a?(Regexp) ||
             constraints[:boundary_constraints].is_a?(String))
          raise ArgumentError.new 'boundary constraints must be a Regexp or String'
        end
      elsif constraints[:feature_constraints] && !constraints[:feature_constraints].is_a?(Hash)
        raise ArgumentError.new 'feature constraints must be a Hash'
      elsif @options[:partial] && !text.end_with?("\n")
        raise ArgumentError.new 'partial parsing requires new-line char at end of text'
      end

      @parse_tonodes.call(text, constraints)
    end

    # Returns human-readable details for the wrapped MeCab library.
    # Overrides `Object#to_s`.
    #
    # - encoded object id
    # - underlying FFI pointer to the MeCab Model
    # - underlying FFI pointer to the MeCab Tagger
    # - underlying FFI pointer to the MeCab Lattice
    # - real file path to MeCab library
    # - options hash
    # - list of dictionaries
    # - MeCab version
    # @return [String] encoded object id, underlying FFI pointer,
    #   file path to MeCab library, options hash,
    #   list of dictionaries and MeCab version
    def to_s
      [ super.chop,
        "@model=#{@model},", 
        "@tagger=#{@tagger},", 
        "@lattice=#{@lattice},", 
        "@libpath=\"#{@libpath}\",",
        "@options=#{@options.inspect},", 
        "@dicts=#{@dicts.to_s},", 
        "@version=#{@version.to_s}>" ].join(' ')
    end

    # Overrides `Object#inspect`.
    # @return [String] encoded object id, FFI pointer, options hash,
    #   list of dictionaries, and MeCab version
    # @see #to_s
    def inspect
      self.to_s
    end

    # Returns a `Proc` that will properly free resources
    # when this instance is garbage collected.
    # @param mptr [FFI::Pointer] pointer to Model
    # @param tptr [FFI::Pointer] pointer to Tagger
    # @param lptr [FFI::Pointer] pointer to Lattice
    # @return [Proc] to release MeCab resources properly
    def self.create_free_proc(mptr, tptr, lptr)
      Proc.new do
        self.mecab_lattice_destroy(lptr)
        self.mecab_destroy(tptr)
        self.mecab_model_destroy(mptr)
      end
    end

    private

    # @private
    # MeCab eats all leading and training whitespace char
    def tokenize_by_pattern(text, pattern)
      matches = text.scan(pattern)
      
      acc = []
      tmp = text
      matches.each_with_index do |m,i|
        bef, mat, aft = tmp.partition(m)
        unless bef.empty?
          acc << [bef.strip, false]
        end
        unless mat.empty?
          acc << [mat.strip, true]
        end
        if i==matches.size-1 && !aft.empty?
          acc << [aft.strip, false]
        end
        tmp = aft
      end
      acc
    end

    def tokenize_by_features(text, features)
      acc = []
      acc << [text.strip, false]

      features.each do |feature|
        acc.each_with_index do |e,i|
          if !e.last
            tmp = tokenize_by_pattern(e.first, feature)
            if !tmp.empty?
              acc.delete_at(i)
              acc.insert(i, *tmp)
            end
          end
        end
      end
      acc
    end
  end

  # `MeCabError` is a general error class for the `Natto` module.
  class MeCabError < RuntimeError; end
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

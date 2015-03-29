# coding: utf-8
require 'natto/binding'
require 'natto/option_parse'
require 'natto/struct'

module Natto 
  # `MeCab` is a wrapper class for the MeCab `Tagger`.
  # Options to the MeCab `Tagger` are passed in as a string
  # (MeCab command-line style) or as a Ruby-style hash at
  # initialization.
  #
  # ## Usage
  #
  #     require 'natto'
  #
  #     text = '凡人にしか見えねえ風景ってのがあるんだよ。'
  #
  #     nm = Natto::MeCab.new
  #     => #<Natto::MeCab:0x28d3bdc8 \
  #          @tagger=#<FFI::Pointer address=0x28afb980>, \
  #          @libpath="/usr/local/lib/libmecab.so"       \
  #          @options={},                                \
  #          @dicts=[#<Natto::DictionaryInfo:0x289a1f14  \
  #                    @filepath="/usr/local/lib/mecab/dic/ipadic/sys.dic", \
  #                    charset=utf8,                     \
  #                    type=0>],                         \
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

    # @return [FFI:Pointer] pointer to MeCab tagger.
    attr_reader :tagger
    # @return [String] absolute filepath to MeCab library.
    attr_reader :libpath
    # @return [Hash] MeCab options as key-value pairs.
    attr_reader :options
    # @return [Array] listing of all of dictionaries referenced.
    attr_reader :dicts
    # @return [String] `MeCab` version.
    attr_reader :version

    # Initializes the wrapped `Tagger` instance with the
    # given `options`.
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
    # addition to Ruby-style `Hash`es</p>
    # <i>Use single-quotes to preserve format options that contain escape chars.</i><br/>
    # e.g.<br/>
    #
    #     nm = Natto::MeCab.new(node_format: '%m¥t%f[7]¥n')
    #     => #<Natto::MeCab:0x28d2ae10 
    #          @tagger=#<FFI::Pointer address=0x28a97980>, \
    #          @libpath="/usr/local/lib/libmecab.so",      \
    #          @options={:node_format=>"%m¥t%f[7]¥n"},     \
    #          @dicts=[#<Natto::DictionaryInfo:0x28d2a85c  \
    #                    @filepath="/usr/local/lib/mecab/dic/ipadic/sys.dic" \
    #                    charset=utf8,                     \
    #                    type=0>]                          \
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
    #
    # @param options [Hash, String] the MeCab options for tagger
    # @raise [MeCabError] if `mecab` cannot be initialized with the given `options`
    def initialize(options={})
      @options = self.class.parse_mecab_options(options) 
      @dicts = []
      # TODO invoke function for enhancing MeCabNode after this point

      opt_str  = self.class.build_options_str(@options)
      @tagger  = self.class.mecab_new2(opt_str)
      @libpath = self.class.find_library
      raise MeCabError.new("Could not initialize MeCab with options: '#{opt_str}'") if @tagger.address == 0x0

      self.mecab_set_theta(@tagger, @options[:theta]) if @options[:theta]
      self.mecab_set_lattice_level(@tagger, @options[:lattice_level]) if @options[:lattice_level]
      self.mecab_set_all_morphs(@tagger, 1) if @options[:all_morphs]
      self.mecab_set_partial(@tagger, 1) if @options[:partial]
       
      # Define lambda for each major parsing type: _tostr, _tonode,
      # boundary constraint _tostr, boundary constraint _node;
      # and each parsing type will support both normal and N-best
      # options
      @parse_tostr = ->(text) {
        if @options[:nbest] && @options[:nbest] > 1
          #self.mecab_set_lattice_level(@tagger, (@options[:lattice_level] || 1))
          retval = self.mecab_nbest_sparse_tostr(@tagger, @options[:nbest], text) || 
                raise(MeCabError.new(self.mecab_strerror(@tagger))) 
        else
          retval = self.mecab_sparse_tostr(@tagger, text) || 
                raise(MeCabError.new(self.mecab_strerror(@tagger))) 
        end

        retval.force_encoding(Encoding.default_external)
      } 

      @parse_tonodes = ->(text) { 
        Enumerator.new do |y|
          if @options[:nbest] && @options[:nbest] > 1
            nlen = @options[:nbest]
            #self.mecab_set_lattice_level(@tagger, (@options[:lattice_level] || 1))
            self.mecab_nbest_init(@tagger, text) 
            nptr = self.mecab_nbest_next_tonode(@tagger)
          else
            nlen = 1
            nptr = self.mecab_sparse_tonode(@tagger, text) 
          end
          raise(MeCabError.new(self.mecab_strerror(@tagger))) if nptr.nil? || nptr.address==0x0

          nlen.times do
            s = text.bytes.to_a
            while nptr && nptr.address != 0x0
              mn = Natto::MeCabNode.new(nptr)
              # ignore BOS nodes, since mecab does so
              if !mn.is_bos?
                s = s.drop_while {|e| (e==0xa || e==0x20)}
                if !s.empty?
                  sarr = []
                  mn.length.times { sarr << s.shift }
                  surf = sarr.pack('C*')
                  mn.surface = surf.force_encoding(Encoding.default_external)
                end
                if @options[:output_format_type] || @options[:node_format]
                  mn.feature = self.mecab_format_node(@tagger, nptr).force_encoding(Encoding.default_external)
                end
                y.yield mn
              end
              nptr = mn.next
            end
            if nlen > 1
              nptr = self.mecab_nbest_next_tonode(@tagger)
            end
          end
        end
      }
      
      @bcparse_tostr = ->(text, boundary_constraints=/./) {
        begin
          lattice = self.mecab_lattice_new()
          raise MeCabError.new("Could not create Lattice") if lattice.address == 0x0

          if @options[:nbest] && @options[:nbest] > 1
            n = @options[:nbest]
            self.mecab_lattice_set_request_type(lattice, MECAB_LATTICE_NBEST)
          else
            n = 1
            self.mecab_lattice_set_request_type(lattice, MECAB_LATTICE_ONE_BEST)
          end
          if @options[:theta]
            self.mecab_lattice_set_theta(lattice, @options[:theta])
          end
          puts "... 1"
          puts @options

          self.mecab_lattice_set_sentence(lattice, text)
          puts "... 2"

          tokens = tokenize(text, boundary_constraints)
          tokens.each do |t|
            puts "#{t.first}, #{t.last}"
          end
          bpos = 0
          tokens.each do |token|
            c = token.first

            self.mecab_lattice_set_boundary_constraint(lattice, bpos, MECAB_TOKEN_BOUNDARY)
            bpos += 1

            mark = token.last ? MECAB_INSIDE_TOKEN : MECAB_ANY_BOUNDARY
            (c-1).times do
              self.mecab_lattice_set_boundary_constraint(lattice, bpos, mark)
              bpos += 1
            end
          end
          puts "... 3"
          puts "bpos? #{bpos}"
          bpos.times do |i|
            puts self.mecab_lattice_get_boundary_constraint(lattice, i)
          end
          puts "... 3.5"

          self.mecab_parse_lattice(@tagger, lattice)
          puts "... 4"
          
          if n > 1
            retval = self.mecab_lattice_nbest_tostr(lattice, n)
          else
            retval = self.mecab_lattice_tostr(lattice)
            puts "... 5"
          end
          retval.force_encoding(Encoding.default_external)
        rescue
          puts "ZOMG"
          raise(MeCabError.new(self.mecab_lattice_strerror(lattice))) 
        ensure
          if lattice.address != 0x0
            puts "clean up"
            self.mecab_lattice_destroy(lattice)
          end
        end
      }
        
      @bcparse_tonodes = ->(text, boundary_constraints=/./) {
        Enumerator.new do |y|
          begin
            lattice = self.mecab_lattice_new()
            raise MeCabError.new("Could not create Lattice") if lattice.address == 0x0

            if @options[:nbest] && @options[:nbest] > 1
              n = @options[:nbest]
              self.mecab_lattice_set_request_type(lattice, MECAB_LATTICE_NBEST)
            else
              n = 1
              self.mecab_lattice_set_request_type(lattice, MECAB_LATTICE_ONE_BEST)
            end
            if @options[:theta]
              self.mecab_lattice_set_theta(lattice, @options[:theta])
            end

            self.mecab_lattice_set_sentence(lattice, text)

            tokens = tokenize(text, boundary_constraints)
            bpos = 0
            tokens.each do |token|
              c = token.first

              self.mecab_lattice_set_boundary_constraint(lattice, bpos, MECAB_TOKEN_BOUNDARY)
              bpos += 1

              mark = token.last ? MECAB_INSIDE_TOKEN : MECAB_ANY_BOUNDARY
              (c-1).times do
                self.mecab_lattice_set_boundary_constraint(lattice, bpos, mark)
                bpos += 1
              end
            end

            self.mecab_parse_lattice(@tagger, lattice)

            n.times do
              check = self.mecab_lattice_next(lattice)
              if check
                nptr = self.mecab_lattice_get_bos_node(lattice)
          
                s = text.bytes.to_a
                while nptr && nptr.address!=0x0
                  mn = Natto::MeCabNode.new(nptr)
                  s = s.drop_while {|e| (e==0xa || e==0x20)}
                  if !s.empty?
                    sarr = []
                    mn.length.times { sarr << s.shift }
                    surf = sarr.pack('C*')
                    mn.surface = surf.force_encoding(Encoding.default_external)
                  end
                  if @options[:output_format_type] || @options[:node_format]
                    mn.feature = self.mecab_format_node(@tagger, nptr).force_encoding(Encoding.default_external)
                  end
                  y.yield mn
                  nptr = mn.next
                end
              end
            end
          rescue
            raise(MeCabError.new(self.mecab_lattice_strerror(lattice))) 
          ensure
            if lattice.address != 0x0
              self.mecab_lattice_destroy(lattice)
            end
          end
        end
      }

      @dicts << Natto::DictionaryInfo.new(Natto::Binding.mecab_dictionary_info(@tagger))
      while @dicts.last.next.address != 0x0
        @dicts << Natto::DictionaryInfo.new(@dicts.last.next)
      end

      @version = self.mecab_version

      ObjectSpace.define_finalizer(self, self.class.create_free_proc(@tagger))
    end
    
    # Parses the given `text`, returning the MeCab output as a single string. 
    # If a block is passed to this method, then node parsing will be used
    # and each node yielded to the given block.
    #
    # Boundary constraint parsing is available via passing in the
    # `boundary_constraints` key in the `options` hash. Boundary constraints
    # parsing provides hints to MeCab on where the morpheme boundaries in the
    # given `text` are located. `boundary_constraints` value may be either a
    # `Regexp` or `String`; please see
    # [String#scan](http://ruby-doc.org/core-2.2.0/String.html#method-i-scan String#scan.
    # The boundary constraint parsed output will be returned as a single
    # string, unless a block is passed to this method for node parsing.
    #
    # @param text [String] the Japanese text to parse
    # @param options [Hash] only the `boundary_constraints` key is available
    # @return [String] parsing result from `mecab`
    # @raise [MeCabError] if the `mecab` tagger cannot parse the given `text`
    # @raise [ArgumentError] if the given string `text` argument is `nil`
    # @see MeCabNode
    def parse(text, options={})
      raise ArgumentError.new 'Text to parse cannot be nil' if text.nil?
      if options[:boundary_constraints]
        if block_given?
          @bcparse_tonodes.call(text, options[:boundary_constraints]).each {|n| yield n }
        else
          @bcparse_tostr.call(text, options[:boundary_constraints])
        end
      else
        if block_given?
          @parse_tonodes.call(text).each {|n| yield n }
        else
          @parse_tostr.call(text)
        end
      end
    end

    # Parses the given string `text`, returning an
    # {http://www.ruby-doc.org/core-2.1.5/Enumerator.html Enumerator} that may be
    # used to iterate over the resulting {MeCabNode} objects. This is more 
    # efficient than parsing to a simple string, since each node's
    # information will not be materialized all at once as it is with
    # string output.
    #
    # MeCab nodes contain much more detailed information about
    # the morpheme. Node-formatting  may also be used to customize
    # the resulting node's `feature` attribute.
    #
    # Boundary constraint parsing is available via passing in the
    # `boundary_constraints` key in the `options` hash. Boundary constraints
    # parsing provides hints to MeCab on where the morpheme boundaries in the
    # given `text` are located. `boundary_constraints` value may be either a
    # `Regexp` or `String`; please see 
    # [String#scan](http://ruby-doc.org/core-2.2.0/String.html#method-i-scan String#scan).
    #
    # @param text [String] the Japanese text to parse
    # @param options [Hash] only the `boundary_constraints` key is available
    # @return [Enumerator] of MeCabNode instances
    # @raise [MeCabError] if the `mecab` tagger cannot parse the given `text`
    # @raise [ArgumentError] if the given string `text` argument is `nil`
    # @see MeCabNode
    # @see http://ruby-doc.org/core-2.2.1/Enumerator.html
    def enum_parse(text, options={})
      raise ArgumentError.new 'Text to parse cannot be nil' if text.nil?
      @parse_tonodes.call(text)
    end

    # Returns human-readable details for the wrapped `mecab` tagger.
    # Overrides `Object#to_s`.
    #
    # - encoded object id
    # - underlying FFI pointer to the `mecab` tagger
    # - real file path to `mecab` library
    # - options hash
    # - list of dictionaries
    # - MeCab version
    #
    # @return [String] encoded object id, underlying FFI pointer,
    #   file path to `mecab` library, options hash,
    #   list of dictionaries and MeCab version
    def to_s
      [ super.chop,
        "@tagger=#{@tagger},", 
        "@libpath=\"#{@libpath}\",",
        "@options=#{@options.inspect},", 
        "@dicts=#{@dicts.to_s},", 
        "@version=#{@version.to_s}>" ].join(' ')
    end

    # Overrides `Object#inspect`.
    # 
    # @return [String] encoded object id, FFI pointer, options hash,
    #   list of dictionaries, and MeCab version
    # @see #to_s
    def inspect
      self.to_s
    end

    # Returns a `Proc` that will properly free resources
    # when this `Tagger` instance is garbage collected.
    # The `Proc` returned is registered to be invoked
    # after the `Tagger` instance  owning `tptr` 
    # has been destroyed.
    #
    # @param tptr [FFI::Pointer] pointer to `Tagger`
    # @return [Proc] to release `mecab` resources properly
    def self.create_free_proc(tptr)
      Proc.new do
        self.mecab_destroy(tptr)
      end
    end

    private

    # @private
    def tokenize(text, pattern)
      matches = text.scan(pattern)
      
      acc =[]
      tmp = text
      matches.each_with_index do |m,i|
        bef, mat, aft = tmp.partition(m)
        unless bef.empty?
          acc << [bef.bytes.count, false]
        end
        unless mat.empty?
          acc << [mat.bytes.count, true]
        end
        if i==matches.size-1 and !aft.empty?
          acc << [aft.bytes.count, false]
        end
        tmp = aft
      end
      acc
    end
  end

  # `MeCabError` is a general error class 
  # for the `Natto` module.
  class MeCabError < RuntimeError; end
end

# Copyright (c) 2015, Brooke M. Fujita.
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

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
  #     mecab = Natto::MeCab.new(:output_format_type=>'wakati')
  #     => #<Natto::MeCab:0x28d896b8 @ptr=#<FFI::Pointer address=0x28e378b8>, \
  #                                  @options={:output_format_type=>"wakati"}, \
  #                                  @dicts=[/usr/local/lib/mecab/dic/ipadic/sys.dic], \ 
  #                                  @version="0.98">     
  #
  #     output = mecab.parse('ネバネバの組み合わせ美味しいです。').split
  #
  #     output.each do |token|
  #       puts token
  #     end
  #     => ネバネバ
  #        の
  #        組み合わせ
  #        美味しい
  #        です
  #        。
  #
  class MeCab
    include Natto::Binding

    attr_reader :options, :dicts, :version

    # Supported options to the <tt>mecab</tt> parser.
    # See the <tt>mecab</tt> help for more details. 
    SUPPORTED_OPTS = [  :rcfile, :dicdir, :userdic, :lattice_level, :all_morphs,
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
    #     mecab = Natto::MeCab.new(:node_format=>'%m\t%f[7]\n')
    #     => #<Natto::MeCab:0x28d82f20 @ptr=#<FFI::Pointer address=0x28e378a8>, \
    #                                  @options={:node_format=>"%m\\t%f[7]\\n"}, \
    #                                  @dicts=[/usr/local/lib/mecab/dic/ipadic/sys.dic], \
    #                                  @version="0.98">
    #
    #     puts mecab.parse('簡単で美味しくて良いですよね。')
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
      @options = options
      @dicts = []

      opt_str = self.class.build_options_str(@options)
      @ptr = self.mecab_new2(opt_str)
      raise MeCabError.new("Could not initialize MeCab with options: '#{opt_str}'") if @ptr.address == 0x0
 
      self.mecab_set_theta(@ptr, @options[:theta].to_f) if @options[:theta]
      self.mecab_set_lattice_level(@ptr, @options[:lattice_level].to_i) if @options[:lattice_level]
      self.mecab_set_all_morphs(@ptr, 1) if @options[:all_morphs]

      if @options[:nbest] && @options[:nbest] > 1
        # nbest, plain
        self.mecab_set_lattice_level(@ptr, (@options[:lattice_level] || 1))
        @parse_proc = lambda { |str| 
          self.mecab_nbest_init(@ptr, str) || raise(MeCabError.new(self.mecab_strerror(@ptr)))
          return self.mecab_nbest_sparse_tostr(@ptr, @options[:nbest], str) || 
                raise(MeCabError.new(self.mecab_strerror(@ptr))) } 
      else
        # default parsing
        @parse_proc = lambda { |str|
          return self.mecab_sparse_tostr(@ptr, str) || raise(MeCabError.new(self.mecab_strerror(@ptr))) }
      end
      require 'natto/rb19_encoding'

      @dicts << Natto::DictionaryInfo.new(Natto::Binding.mecab_dictionary_info(@ptr))
      while @dicts.last.next.address != 0x0
        @dicts << Natto::DictionaryInfo.new(@dicts.last.next)
      end

      @version = self.mecab_version

      ObjectSpace.define_finalizer(self, self.class.create_free_proc(@ptr))
    end
    
    # Parses the given string <tt>str</tt>.
    #
    # @param [String] str
    # @return parsing result from <tt>mecab</tt>
    # @raise [MeCabError] if the <tt>mecab</tt> parser cannot parse the given string <tt>str</tt>
    def parse(str)
      @parse_proc.call(str)
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

    # Overrides <tt>Object#inspect</tt> by returning the string representation of <tt>self</tt>.
    #
    # @return [String] <tt>self.to_s</tt>
    def inspect
      to_s
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
    # @return string-representation of the options to the <tt>mecab</tt> parser
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
      opt.join(" ")
    end
  end

  # <tt>MeCabError</tt> is a general error class 
  # for the <tt>Natto</tt> module.
  class MeCabError < RuntimeError; end

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
  #     mecab = Natto::MeCab.new
  #
  #     sysdic = m.dicts.first
  #
  #     puts sysdic.filename
  #     => /usr/local/lib/mecab/dic/ipadic/sys.dic
  #
  #     puts sysdic.charset
  #     => utf8
  #
  # It is also possible to use the <tt>Symbol</tt> for the
  # <tt>mecab</tt> dictionary member to index into the 
  # <tt>FFI::Struct</tt> layout associative array like so:
  #     
  #     puts sysdic[:filename]
  #     => /usr/local/lib/mecab/dic/ipadic/sys.dic
  #
  #     puts sysdic[:charset]
  #     => utf8
  #
  class DictionaryInfo < FFI::Struct

    layout  :filename, :string,
            :charset,  :string,
            :size,     :uint,
            :type,     :int,
            :lsize,    :uint,
            :rsize,    :uint,
            :version,  :ushort,
            :next,     :pointer
   
    # Hack to avoid that deprecation message Object#type thrown in Ruby 1.8.7.
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

    # Provides accessor methods for the members of the <tt>DictionaryInfo</tt> structure.
    #
    # @param [String] attr_name
    # @return member values for the <tt>mecab</tt> dictionary
    # @raise [NoMethodError] if <tt>attr_name</tt> is not a member of this <tt>mecab</tt> dictionary <tt>FFI::Struct</tt> 
    def method_missing(attr_name)
      member_sym = attr_name.id2name.to_sym
      return self[member_sym] if self.members.include?(member_sym)
      raise(NoMethodError.new("undefined method '#{attr_name}' for #{self}"))
    end

    # Returns the full-path file name for this dictionary. Overrides <tt>Object#to_s</tt>.
    #
    # @return [String] full-path filename for this dictionary
    def to_s
      self[:filename]
    end
  end
end

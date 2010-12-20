# -*- coding: UTF-8 -*-
require 'rubygems' if RUBY_VERSION.to_f < 1.9

module Natto
  require 'ffi'

  class MeCab
    SUPPORTED_OPTS = [ :rcfile, :dicdir, :userdic, :output_format_type, :lattice_level, 
                       :node_format, :unk_format, :bos_format, :eos_format, :eon_format,
                       :unk_feature, :nbest, :theta, :cost_factor ]
                       # :all_morphs, :partial, :allocate_sentence ]
    attr_reader :ptr

    def initialize(options={})
      opt_str = self.class.build_options_str(options)
      #@ptr = FFI::MemoryPointer.new :pointer
      @ptr = Natto::Binding.mecab_new2(opt_str)
      puts @ptr.inspect
      raise MeCabError.new("MeCab initialiation error with '#{opt_str}'") if @ptr.address == 0
      #@dict = Natto::DictionaryInfo.new(Natto::Binding.mecab_dictionary_info(@ptr))
      ObjectSpace.define_finalizer(self, self.class.create_free_proc(@ptr))
    end

    def parse(s)
      Natto::Binding.mecab_sparse_tostr(@ptr, s) || 
        raise(MeCabError.new(Natto::Binding.mecab_strerror(@ptr)))
    end
    
    def self.create_free_proc(ptr)
      Proc.new do
        #puts "mecab_destroy #{ptr}"
        Natto::Binding.mecab_destroy(ptr)
      end
    end

    def self.build_options_str(options={})
      opt = []
      SUPPORTED_OPTS.each do |k|
        if options.has_key? k
          key = k.to_s.gsub('_', '-')  
          opt << "--#{key}=#{options[k]}"
        end
      end
      opt.join(" ")
    end
  end
 
  class MeCabError < RuntimeError; end

  class DictionaryInfo < FFI::Struct
    layout  :filename, :string,
            :charset,  :string,
            :size,     :uint,
            :type,     :int,
            :lsize,    :uint,
            :rsize,    :uint,
            :version,  :ushort,
            :next,     :pointer 
  end

  module Binding
    require 'rbconfig'
    extend FFI::Library

    MECAB_PATH = 'MECAB_PATH'

    def self.included(base)
      base.extend(ClassMethods)
    end

    def self.find_library
      host_os = RbConfig::CONFIG['host_os']

      if host_os =~ /mswin|mingw/i
        raise LoadError, "Please set #{MECAB_PATH} to full path to libmecab.dll"
      elsif host_os =~ /cygwin/i
        'cygmecab-1'
      else
        'mecab'
      end
    end

    ffi_lib(ENV[MECAB_PATH] || find_library)

    attach_function :mecab_version, [], :string
    attach_function :mecab_new2, [:string], :pointer
    attach_function :mecab_destroy, [:pointer], :void
    attach_function :mecab_sparse_tostr, [:pointer, :string], :string
    attach_function :mecab_strerror, [:pointer],:string
    attach_function :mecab_dictionary_info, [:pointer], :pointer

    module ClassMethods
      def mecab_version
        Natto::Binding.mecab_version
      end
    end
  end
end

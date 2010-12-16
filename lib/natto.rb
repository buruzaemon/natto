# -*- coding: UTF-8 -*-
require 'rubygems' if RUBY_VERSION.to_f < 1.9

module Natto
  require 'ffi'

  class MeCab
    attr_reader :dict

    def initialize(options)
      options ||= {}
      defaults = { :user_dic => nil, :output_fmt => nil }
      options = defaults.merge(options)
      option_str = ""
      option_str += "-d"
      @ptr = Natto::Binding.mecab_new2("-Owakati")
      @dict = Natto::DictionaryInfo.new(Natto::Binding.mecab_dictionary_info(@ptr))
      ObjectSpace.define_finalizer(@ptr, self.class.method(:finalize).to_proc)
    end

    def self.finalize(id)
      instance = ObjectSpace._id2ref(id)
      Natto::Binding.mecab_destroy(instance)
      puts "finalized!"
    end

    def parse(s)
      Natto::Binding.mecab_sparse_tostr(@ptr, s) || 
        raise(MeCabError.new(Natto::Binding.mecab_strerror(@ptr)))
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

begin
m = Natto::MeCab.new(:output_fmt => 'wakati')
puts m.dict[:filename]
puts m.dict[:charset]
end

puts ".. so, what happened?"

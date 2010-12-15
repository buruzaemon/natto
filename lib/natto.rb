require 'rubygems' if RUBY_VERSION.to_f < 1.9
require 'ffi'
require 'rbconfig'

module Natto
  extend FFI::Library

  def self.included(base)
    base.extend(ClassMethods)
  end

  def self.find_library
    host_os = RbConfig::CONFIG['host_os']

    if host_os =~ /mswin|mingw/i
      raise LoadError, "Please set MECAB_PATH to full path to libmecab.dll"
    elsif host_os =~ /cygwin/i
      'cygmecab-1'
    else
      'mecab'
    end
  end

  ffi_lib(ENV['MECAB_PATH'] || find_library)

  attach_function :mecab_version, [], :string

  class MeCab
    attr_reader :ptr_m

    def initialize(options={:user_dic=>nil, :output_fmt=>nil})

      @ptr_m = Natto.mecab_new2("")
      ObjectSpace.define_finalizer(@ptr_m, self.class.method(:finalize).to_proc)
    end

    def self.finalize(id)
      instance = ObjectSpace._id2ref(id)
      Natto.mecab_destroy(instance.ptr_m)
      puts "finalized!"
    end

    def parse(s)
      Natto.mecab_sparse_tostr(@ptr_m, s) || raise(MeCabError.new(Natto.mecab_strerror(@ptr_m)))
    end

  end
  attach_function :mecab_new2, [:string], :pointer
  attach_function :mecab_destroy, [:pointer], :void
  attach_function :mecab_sparse_tostr, [:pointer, :string], :string
 
  class MeCabError < RuntimeError; end
  attach_function :mecab_strerror, [:pointer],:string

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
  attach_function :mecab_dictionary_info, [:pointer], :pointer


  module ClassMethods
    def mecab_version
      Natto.mecab_version
    end
  end
end

begin
#ptr_m = Natto.mecab_new2("")
m = Natto::MeCab.new("")
ptr_m = m.ptr_m
ptr_d = Natto.mecab_dictionary_info(ptr_m)
dict = Natto::DictionaryInfo.new ptr_d
puts dict[:filename]
puts dict[:charset]
end

puts ".. so, what happened?"

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

    if host_os =~ /mswin|mingw/
      raise LoadError, "Please set MECAB_PATH to full path to libmecab.dll"
    elsif host_os =~ /cygwin/
      'cygmecab-1'
    else
      'mecab'
    end
  end

  ffi_lib(ENV['MECAB_PATH'] || find_library)

  attach_function :mecab_new2, [:string], :pointer
  attach_function :mecab_version, [], :string
  attach_function :mecab_sparse_tostr, [:pointer, :string], :string
  attach_function :mecab_strerror, [:pointer],:string
  attach_function :mecab_destroy, [:pointer], :void

  module ClassMethods
    def mecab_version
      Natto.mecab_version
    end
  end
end



# coding: utf-8
module Natto

  # Module `Binding` encapsulates methods and behavior 
  # which are made available via `FFI` bindings to 
  # `mecab`.
  module Binding
    require 'ffi'
    require 'rbconfig'
    extend FFI::Library

    # String name for the environment variable used by 
    # `Natto` to indicate the absolute pathname
    # to the `mecab` library.
    MECAB_PATH = 'MECAB_PATH'.freeze
    
    # @private
    def self.included(base)
      base.extend(ClassMethods)
    end

    # Returns the absolute pathname to the `mecab` library based on 
    # the runtime environment.
    # 
    # @return [String] absolute pathname to the `mecab` library
    # @raise [LoadError] if the library cannot be located
    def self.find_library
      return File.absolute_path(ENV[MECAB_PATH]) if ENV[MECAB_PATH]

      host_os = RbConfig::CONFIG['host_os']

      if host_os =~ /mswin|mingw/i
        require 'win32/registry'
        begin
          base = nil
          Win32::Registry::HKEY_CURRENT_USER.open('Software\MeCab') do |r|
            base = r['mecabrc'].split('etc').first
          end
          lib = File.join(base, 'bin/libmecab.dll')
          File.absolute_path(lib)
        rescue
          raise LoadError, "Please set #{MECAB_PATH} to the full path to libmecab.dll"
        end
      else
        require 'open3'
        if host_os =~ /darwin/i
          ext = 'dylib'
        else
          ext = 'so'
        end

        begin
          base, lib = nil, nil
          cmd = 'mecab-config --libs'
          Open3.popen3(cmd) do |stdin,stdout,stderr|
            toks = stdout.read.split
            base = toks[0][2..-1]
            lib  = toks[1][2..-1]
          end
          File.absolute_path(File.join(base, "lib#{lib}.#{ext}"))
        rescue
          raise LoadError, "Please set #{MECAB_PATH} to the full path to libmecab.#{ext}"
        end
      end
    end

    ffi_lib find_library

    # new interface
    attach_function :mecab_model_new2, [:string], :pointer
    attach_function :mecab_model_destroy, [:pointer], :void
    attach_function :mecab_model_dictionary_info, [:pointer], :pointer

    # old interface
    attach_function :mecab_new2, [:string], :pointer
    attach_function :mecab_version, [], :string
    attach_function :mecab_strerror, [:pointer],:string
    attach_function :mecab_destroy, [:pointer], :void
    attach_function :mecab_set_partial, [:pointer, :int], :void 
    attach_function :mecab_set_theta, [:pointer, :float], :void
    attach_function :mecab_set_lattice_level, [:pointer, :int], :void 
    attach_function :mecab_set_all_morphs, [:pointer, :int], :void
    attach_function :mecab_sparse_tostr, [:pointer, :string], :string
    attach_function :mecab_sparse_tonode, [:pointer, :string], :pointer
    attach_function :mecab_nbest_init, [:pointer, :string], :int
    attach_function :mecab_nbest_sparse_tostr, [:pointer, :int, :string], :string
    attach_function :mecab_nbest_next_tonode, [:pointer], :pointer
    attach_function :mecab_format_node, [:pointer, :pointer], :string
    attach_function :mecab_dictionary_info, [:pointer], :pointer

    # @private
    module ClassMethods

      def find_library
        Natto::Binding.find_library
      end

      def mecab_model_new2(options_str)
        Natto::Binding.mecab_model_new2(options_str)
      end
      
      def mecab_model_destroy(m_ptr)
        Natto::Binding.mecab_model_destroy(m_ptr)
      end

      def mecab_model_dictionary_info(m_ptr)
        Natto::Binding.mecab_model_dictionary_info(m_ptr)
      end
      
      # ----------------------------------------
      def mecab_new2(options_str)
        Natto::Binding.mecab_new2(options_str)
      end
      
      def mecab_version
        Natto::Binding.mecab_version
      end

      def mecab_strerror(m_ptr)
        Natto::Binding.mecab_strerror(m_ptr)
      end

      def mecab_destroy(m_ptr)
        Natto::Binding.mecab_destroy(m_ptr)
      end

      def mecab_set_partial(m_ptr, ll)
        Natto::Binding.mecab_set_partial(m_ptr, ll)
      end
      
      def mecab_set_theta(m_ptr, t)
        Natto::Binding.mecab_set_theta(m_ptr, t)
      end

      def mecab_set_lattice_level(m_ptr, ll)
        Natto::Binding.mecab_set_lattice_level(m_ptr, ll)
      end
      
      def mecab_set_all_morphs(m_ptr, am)
        Natto::Binding.mecab_set_all_morphs(m_ptr, am)
      end

      def mecab_sparse_tostr(m_ptr, str)
        Natto::Binding.mecab_sparse_tostr(m_ptr, str)
      end
      
      def mecab_sparse_tonode(m_ptr, str)
        Natto::Binding.mecab_sparse_tonode(m_ptr, str)
      end

      def mecab_nbest_next_tonode(m_ptr)
        Natto::Binding.mecab_nbest_next_tonode(m_ptr)
      end

      def mecab_nbest_init(m_ptr, str)
        Natto::Binding.mecab_nbest_init(m_ptr, str)
      end

      def mecab_nbest_sparse_tostr(m_ptr, n, str)
        Natto::Binding.mecab_nbest_sparse_tostr(m_ptr, n, str)
      end

      def mecab_nbest_next_tonode(m_ptr)
        Natto::Binding.mecab_nbest_next_tonode(m_ptr)
      end

      def mecab_format_node(m_ptr, n_ptr)
        Natto::Binding.mecab_format_node(m_ptr, n_ptr)
      end
      
      def mecab_dictionary_info(m_ptr)
        Natto::Binding.mecab_dictionary_info(m_ptr)
      end
    end
  end
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

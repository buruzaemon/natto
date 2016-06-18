# coding: utf-8
module Natto

  # Module `Binding` encapsulates methods and behavior 
  # which are made available via `FFI` bindings to MeCab.
  module Binding
    require 'ffi'
    require 'rbconfig'
    extend FFI::Library

    MECAB_PATH = 'MECAB_PATH'.freeze
    
    # @private
    def self.included(base)
      base.extend(ClassMethods)
    end

    # Returns the absolute pathname to the MeCab library based on 
    # the runtime environment.
    # @return [String] absolute pathname to the MeCab library
    # @raise [LoadError] if the library cannot be located
    def self.find_library
      if ENV[MECAB_PATH]
        File.absolute_path(ENV[MECAB_PATH])
      else
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
    end

    ffi_lib find_library

    # Model interface
    attach_function :mecab_model_new2, [:string], :pointer
    attach_function :mecab_model_destroy, [:pointer], :void
    attach_function :mecab_model_new_tagger, [:pointer], :pointer
    attach_function :mecab_model_new_lattice, [:pointer], :pointer
    attach_function :mecab_model_dictionary_info, [:pointer], :pointer

    # Tagger interface
    attach_function :mecab_destroy, [:pointer], :void
    attach_function :mecab_version, [], :string
    attach_function :mecab_strerror, [:pointer],:string
    attach_function :mecab_format_node, [:pointer, :pointer], :string

    # Lattice interface
    attach_function :mecab_lattice_destroy, [:pointer], :void
    attach_function :mecab_lattice_clear, [:pointer], :void
    attach_function :mecab_lattice_is_available, [:pointer], :int
    attach_function :mecab_lattice_strerror, [:pointer], :string

    attach_function :mecab_lattice_get_sentence, [:pointer], :string
    attach_function :mecab_lattice_set_sentence, [:pointer, :string], :void
    attach_function :mecab_lattice_get_size, [:pointer], :int
    attach_function :mecab_lattice_set_theta, [:pointer, :float], :void
    attach_function :mecab_lattice_set_z, [:pointer, :float], :void
    attach_function :mecab_lattice_get_request_type, [:pointer], :int
    attach_function :mecab_lattice_add_request_type, [:pointer, :int], :void
    attach_function :mecab_lattice_set_request_type, [:pointer, :int], :void
    attach_function :mecab_lattice_get_boundary_constraint, [:pointer, :int], :int
    attach_function :mecab_lattice_set_boundary_constraint, [:pointer, :int, :int], :void
    attach_function :mecab_lattice_get_feature_constraint, [:pointer, :int], :string
    attach_function :mecab_lattice_set_feature_constraint, [:pointer, :int, :int, :string], :void

    attach_function :mecab_parse_lattice, [:pointer, :pointer], :int
    attach_function :mecab_lattice_next, [:pointer], :int
    attach_function :mecab_lattice_tostr, [:pointer], :string
    attach_function :mecab_lattice_nbest_tostr, [:pointer, :int], :string
    attach_function :mecab_lattice_get_bos_node, [:pointer], :pointer

    # @private
    module ClassMethods

      def find_library
        Natto::Binding.find_library
      end

      # Model interface ------------------------
      def mecab_model_new2(opts_str)
        Natto::Binding.mecab_model_new2(opts_str)
      end

      def mecab_model_destroy(mptr)
        Natto::Binding.mecab_model_destroy(mptr)
      end

      def mecab_model_new_tagger(mptr)
        Natto::Binding.mecab_model_new_tagger(mptr)
      end

      def mecab_model_new_lattice(mptr)
        Natto::Binding.mecab_model_new_lattice(mptr)
      end

      def mecab_model_dictionary_info(mptr)
        Natto::Binding.mecab_model_dictionary_info(mptr)
      end

      # Tagger interface -----------------------
      def mecab_destroy(tptr)
        Natto::Binding.mecab_destroy(tptr)
      end

      def mecab_version
        Natto::Binding.mecab_version
      end

      def mecab_strerror(tptr)
        Natto::Binding.mecab_strerror(tptr)
      end

      def mecab_format_node(tptr, nptr)
        Natto::Binding.mecab_format_node(tptr, nptr)
      end

      # Lattice interface ----------------------
      def mecab_lattice_destroy(lptr)
        Natto::Binding.mecab_lattice_destroy(lptr)
      end
    
      def mecab_lattice_clear(lptr)
        Natto::Binding.mecab_lattice_clear(lptr)
      end
    
      def mecab_lattice_is_available(lptr)
        Natto::Binding.mecab_lattice_is_available(lptr)
      end

      def mecab_lattice_strerror(lptr)
        Natto::Binding.mecab_lattice_strerror(lptr)
      end

      def mecab_lattice_get_sentence(lptr)
        Natto::Binding.mecab_lattice_get_sentence(lptr)
      end

      def mecab_lattice_set_sentence(lptr, str)
        Natto::Binding.mecab_lattice_set_sentence(lptr, str)
      end

      def mecab_lattice_get_size(lptr)
        Natto::Binding.mecab_lattice_get_size(lptr)
      end
   
      def mecab_lattice_set_theta(lptr, t)
        Natto::Binding.mecab_lattice_set_theta(lptr, t)
      end

      def mecab_lattice_set_z(lptr, z)
        Natto::Binding.mecab_lattice_set_z(lptr, z)
      end

      def mecab_lattice_get_request_type(lptr)
        Natto::Binding.mecab_lattice_get_request_type(lptr)
      end
      
      def mecab_lattice_add_request_type(lptr, rt)
        Natto::Binding.mecab_lattice_add_request_type(lptr, rt)
      end

      def mecab_lattice_set_request_type(lptr, rtype)
        Natto::Binding.mecab_lattice_set_request_type(lptr, rtype)
      end

      def mecab_lattice_get_boundary_constraint(lptr, pos)
        Natto::Binding.mecab_lattice_get_boundary_constraint(lptr, pos)
      end

      def mecab_lattice_set_boundary_constraint(lptr, pos, btype)
        Natto::Binding.mecab_lattice_set_boundary_constraint(lptr, pos, btype)
      end

      def mecab_lattice_get_feature_constraint(lptr, bpos)
        Natto::Binding.mecab_lattice_get_feature_constraint(lptr, bpos)
      end

      def mecab_lattice_set_feature_constraint(lptr, bpos, epos, feat)
        Natto::Binding.mecab_lattice_set_feature_constraint(lptr, 
                                                            bpos,
                                                            epos,
                                                            feat)
      end

      def mecab_parse_lattice(tptr, lptr)
        Natto::Binding.mecab_parse_lattice(tptr, lptr)
      end

      def mecab_lattice_next(lptr)
        Natto::Binding.mecab_lattice_next(lptr)
      end
 
      def mecab_lattice_tostr(lptr)
        Natto::Binding.mecab_lattice_tostr(lptr)
      end

      def mecab_lattice_nbest_tostr(lptr, n)
        Natto::Binding.mecab_lattice_nbest_tostr(lptr, n)
      end

      def mecab_lattice_get_bos_node(lptr)
        Natto::Binding.mecab_lattice_get_bos_node(lptr)
      end
    end
  end
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

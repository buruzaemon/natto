# coding: utf-8

module Natto

  # Module <tt>Binding</tt> encapsulates methods and behavior 
  # which are made available via <tt>FFI</tt> bindings to 
  # <tt>mecab</tt>.
  module Binding
    require 'ffi'
    require 'rbconfig'
    extend FFI::Library

    # String name for the environment variable used by 
    # <tt>Natto</tt> to indicate the exact name / full path
    # to the <tt>mecab</tt> library.
    MECAB_PATH = 'MECAB_PATH'.freeze
    
    # @private
    def self.included(base)
      base.extend(ClassMethods)
    end

    # Returns the name of the <tt>mecab</tt> library based on 
    # the runtime environment. The value of the environment
    # parameter <tt>MECAB_PATH</tt> is checked before this
    # function is invoked, and in the case of Windows, a
    # <tt>LoadError</tt> will be raised if <tt>MECAB_PATH</tt>
    # is <b>not</b> set to the full path of the <tt>mecab</tt>
    # library.
    # @return name of the <tt>mecab</tt> library
    # @raise [LoadError] if MECAB_PATH environment variable is not set in Windows
    # <br/>
    # e.g., for bash on UNIX/Linux
    #
    #     export MECAB_PATH=/usr/local/lib/libmecab.so
    #
    # e.g., on Windows
    #
    #     set MECAB_PATH=C:\Program Files\MeCab\bin\libmecab.dll
    #
    # e.g., for Cygwin
    #
    #     export MECAB_PATH=cygmecab-1
    #
    # e.g., from within a Ruby program
    #
    #     ENV['MECAB_PATH']=/usr/local/lib/libmecab.so
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

    attach_function :mecab_new2, [:string], :pointer
    attach_function :mecab_version, [], :string
    attach_function :mecab_strerror, [:pointer],:string
    attach_function :mecab_destroy, [:pointer], :void
  
    attach_function :mecab_set_theta, [:pointer, :float], :void
    attach_function :mecab_set_lattice_level, [:pointer, :int], :void 
    attach_function :mecab_set_all_morphs, [:pointer, :int], :void
    
    attach_function :mecab_sparse_tostr, [:pointer, :string], :string
    attach_function :mecab_sparse_tonode, [:pointer, :string], :pointer
    
    attach_function :mecab_nbest_init, [:pointer, :string], :int
    attach_function :mecab_nbest_sparse_tostr, [:pointer, :int, :string], :string
    attach_function :mecab_nbest_next_tonode, [:pointer], :pointer
    
    attach_function :mecab_dictionary_info, [:pointer], :pointer

    attach_function :mecab_parse_lattice, [:pointer, :pointer], :int
    attach_function :mecab_lattice_new, [], :pointer
    attach_function :mecab_lattice_destroy, [:pointer], :void
    attach_function :mecab_lattice_get_begin_nodes, [:pointer, :int], :pointer
    attach_function :mecab_lattice_get_end_nodes, [:pointer, :int], :pointer
    attach_function :mecab_lattice_get_sentence, [:pointer], :string
    attach_function :mecab_lattice_set_sentence, [:pointer, :string], :void
    attach_function :mecab_lattice_get_size, [:pointer], :int
    attach_function :mecab_lattice_next, [:pointer], :int
    attach_function :mecab_lattice_get_request_type, [:pointer], :int
    attach_function :mecab_lattice_set_request_type, [:pointer, :int], :void
    attach_function :mecab_lattice_tostr, [:pointer], :string

    # @private
    module ClassMethods
      def mecab_do(argc, argv)
        Natto::Binding.mecab_do(argc, argv)
      end
      
      def mecab_new2(options_str)
        Natto::Binding.mecab_new2(options_str)
      end
      
      def mecab_version
        Natto::Binding.mecab_version
      end

      def mecab_strerror(ptr)
        Natto::Binding.mecab_strerror(ptr)
      end

      def mecab_destroy(ptr)
        Natto::Binding.mecab_destroy(ptr)
      end

      def mecab_set_theta(ptr, t)
        Natto::Binding.mecab_set_theta(ptr, t)
      end

      def mecab_set_lattice_level(ptr, ll)
        Natto::Binding.mecab_set_lattice_level(ptr, ll)
      end

      def mecab_set_all_morphs(ptr, am)
        Natto::Binding.mecab_set_all_morphs(ptr, am)
      end

      def mecab_sparse_tostr(ptr, str)
        Natto::Binding.mecab_sparse_tostr(ptr, str)
      end
      
      def mecab_sparse_tonode(ptr, str)
        Natto::Binding.mecab_sparse_tonode(ptr, str)
      end

      def mecab_nbest_next_tonode(ptr)
        Natto::Binding.mecab_nbest_next_tonode(ptr)
      end

      def mecab_nbest_init(ptr, str)
        Natto::Binding.mecab_nbest_init(ptr, str)
      end

      def mecab_nbest_sparse_tostr(ptr, n, str)
        Natto::Binding.mecab_nbest_sparse_tostr(ptr, n, str)
      end

      def mecab_dictionary_info(ptr)
        Natto::Binding.mecab_dictionary_info(ptr)
      end

      def mecab_parse_lattice(m_ptr, l_ptr)
        Natto::Binding.mecab_parse_lattice(m_ptr, l_tpr)
      end

      def mecab_lattice_new()
        Natto::Binding.mecab_lattice_new()
      end

      def mecab_lattice_destroy(l_ptr)
        Natto::Binding.mecab_lattice_destroy(l_ptr)
      end

      def mecab_lattice_get_begin_nodes(l_ptr, pos)
        Natto::Binding.mecab_lattice_get_begin_nodes(l_ptr, pos)
      end

      def mecab_lattice_get_end_nodes(l_ptr, pos)
        Natto::Binding.mecab_lattice_get_end_nodes(l_ptr, pos)
      end

      def mecab_lattice_get_sentence(l_ptr)
        Natto::Binding.mecab_lattice_get_sentence(l_ptr)
      end

      def mecab_lattice_set_sentence(l_ptr, str)
        Natto::Binding.mecab_lattice_set_sentence(l_ptr, str)
      end

      def mecab_lattice_get_size(l_ptr)
        Natto::Binding.mecab_lattice_get_size(l_ptr)
      end

      def mecab_lattice_next(l_ptr)
        Natto::Binding.mecab_lattice_next(l_ptr)
      end

      def mecab_lattice_get_request_type(l_ptr)
        Natto::Binding.mecab_lattice_get_request_type(l_ptr)
      end

      def mecab_lattice_set_request_type(l_ptr, rtype)
        Natto::Binding.mecab_lattice_set_request_type(l_ptr, rtype)
      end

      def mecab_lattice_tostr(l_ptr)
        Natto::Binding.mecab_lattice_tostr(l_ptr)
      end
    end
  end
end

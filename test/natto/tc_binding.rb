# coding: utf-8

class TestNattoBinding < Minitest::Test
  def setup
    @ver = `mecab -v`.strip.split.last
    @klass = Class.new do
      include Natto::Binding
    end
  end

  def teardown
    @ver, @klass = nil, nil
  end

  def test_mecab_version
    assert_equal(@ver, @klass.mecab_version)
  end

  def test_functions_included
    [  # Model interface
       :mecab_model_new2,
       :mecab_model_destroy,
       :mecab_model_new_tagger,
       :mecab_model_new_lattice,
       :mecab_model_dictionary_info,
     
       # Tagger interface
       :mecab_destroy,
       :mecab_version,
       :mecab_strerror,
       :mecab_format_node,
    
       # Lattice interface
       :mecab_lattice_destroy,
       :mecab_lattice_clear, 
       :mecab_lattice_is_available,
       :mecab_lattice_strerror,

       :mecab_lattice_get_sentence,
       :mecab_lattice_set_sentence,
       :mecab_lattice_get_size,
       :mecab_lattice_set_theta,
       :mecab_lattice_set_z,
       :mecab_lattice_get_request_type,
       :mecab_lattice_add_request_type,
       :mecab_lattice_set_request_type,
       :mecab_lattice_get_boundary_constraint,
       :mecab_lattice_set_boundary_constraint,
       :mecab_lattice_get_feature_constraint,
       :mecab_lattice_set_feature_constraint,

       :mecab_parse_lattice,
       :mecab_lattice_next,
       :mecab_lattice_tostr,
       :mecab_lattice_nbest_tostr,
       :mecab_lattice_get_bos_node

    ].each do |func|
      assert(@klass.respond_to? func)
    end
  end
end

# Copyright (c) 2020, Brooke M. Fujita.
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
